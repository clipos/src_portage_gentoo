# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Copyright © 2019 ANSSI. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# NOTICE: This eclass was pruned in order to keep only parts needed for CLIP OS.
# The base version was: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/452e94ac38023445938ee6bde7f6a8762f9e4d28/eclass/cros-workon.eclass

# @ECLASS: cros-workon.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for building ChromiumOS packages from git
# @DESCRIPTION:
# A lot of ChromiumOS packages (src/platform/ and src/third_party/) are
# managed in the same way.  You've got a git tree and you want to build
# it.  This automates a lot of that common stuff in one place.

# Array variables. All of the following variables can contain multiple items
# with the restriction being that all of them have to have either:
# - the same number of items globally
# - one item as default for all
# - no items as the cros-workon default
# The exceptions are:
# - CROS_WORKON_PROJECT has to have all items specified.
# - CROS_WORKON_TREE is not listed here because it may not have the same number
#   of items as other array variables when CROS_WORKON_SUBTREE is used.
#   See the variable description below for more details.
ARRAY_VARIABLES=( CROS_WORKON_{SUBTREE,REPO,PROJECT,LOCALNAME,DESTDIR,COMMIT} )

# @ECLASS-VARIABLE: CROS_WORKON_SUBTREE
# @DESCRIPTION:
# Subpaths of the source checkout to be used in the build, separated by
# whitespace. Normally this will be set to directories, but files are also
# allowed if necessary.
# Default value is an empty string, meaning the whole source checkout is used.
# It is strongly recommended to set this variable if the source checkout
# contains multiple packages (e.g. platform2) to avoid unnecessary uprev when
# unrelated files in the repository are modified.
# Access to files outside of these subpaths will be denied.
: ${CROS_WORKON_SUBTREE:=}

# @ECLASS-VARIABLE: CROS_WORKON_REPO
# @DESCRIPTION:
# The base git URL to locate the remote repository.  This is usually the root of
# the GoB server.  It could be any git server, but for infra reliability, our
# policy is to only refer to servers we maintain (e.g. googlesource.com).
# It is combined with CROS_WORKON_PROJECT to form the full URL.
# Look at the cros-constants eclass for common values.
: ${CROS_WORKON_REPO:=/mnt/src}

# @ECLASS-VARIABLE: CROS_WORKON_PROJECT
# @DESCRIPTION:
# The path on the remote server (beneath CROS_WORKON_REPO) to find the git repo.
# This has no relationship to where the source is checked out locally in the
# manifest.  If looking at a manifest.xml, this is the "name" attribute of the
# "project" tag.
: ${CROS_WORKON_PROJECT:=}

# @ECLASS-VARIABLE: CROS_WORKON_LOCALNAME
# @DESCRIPTION:
# The relative path in the local manifest checkout to find the local git
# checkout.  The exact path it is relative to depends on the CATEGORY of the
# ebuild.  For chromeos-base packages, this is relative to src/.  For all other
# packages, it is relative to src/third_party/.  This applies to all ebuilds
# regardless of the overlay they live in.
# If looking at a manifest.xml, this is related to the "path" attribute of the
# "project" tag (although that path is relative to the root of the manifest).
: ${CROS_WORKON_LOCALNAME:=${PN}}

# @ECLASS-VARIABLE: CROS_WORKON_DESTDIR
# @DESCRIPTION:
# Destination directory in ${WORKDIR} for checkout. It must be under ${S}.
# Note that the default is ${S}, but is only referenced in src_unpack for
# ebuilds that would like to override it.
: ${CROS_WORKON_DESTDIR:=}

# @ECLASS-VARIABLE: CROS_WORKON_COMMIT
# @DESCRIPTION:
# Git commit hashes of the source repositories.
# It is guaranteed that files identified by tree hashes in CROS_WORKON_TREE
# can be found in the commit.
# CROW_WORKON_COMMIT is updated only when CROS_WORKON_TREE below is updated,
# so it does not necessarily point to HEAD in the source repository.
: ${CROS_WORKON_COMMIT:=master}

# @ECLASS-VARIABLE: CROS_WORKON_TREE
# @DESCRIPTION:
# Git tree hashes of the contents of the source repositories.
# If CROS_WORKON_SUBTREE is set, tree hashes are taken from specified subpaths;
# otherwise, they are taken from the root directories of the source
# repositories. Therefore note that CROS_WORKON_TREE may have different number
# of entries than CROS_WORKON_COMMIT if multiple subpaths are specified in
# CROS_WORKON_SUBTREE.
# This is used for verifying the correctness of prebuilts. Unlike the commit
# hash, this hash is unaffected by the history of the repository, or by
# commit messages.
: ${CROS_WORKON_TREE:=}

# Scalar variables. These variables modify the behaviour of the eclass.

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIRS_TO_COPY
# @DESCRIPTION:
# Make cros-workon operate exclusively with the subtrees given by this array.
# NOTE: This only speeds up local_cp builds. Inplace/local_git builds are unaffected.
# It will also be disabled by using project arrays, rather than a single project.
: ${CROS_WORKON_SUBDIRS_TO_COPY:=/}

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIRS_TO_REV
# @DESCRIPTION:
# Array of directories in the source tree. If defined, this causes this ebuild
# to only uprev if there are changes within the specified subdirectories.
: ${CROS_WORKON_SUBDIRS_TO_REV:=/}

# We do not need to inherit git-r3 as we don't use any function provided.
DEPEND=">=dev-vcs/git-1.8.2.1[curl]"

# Sanitize all variables, autocomplete where necessary.
# This function possibly modifies all CROS_WORKON_ variables inplace. It also
# provides a global project_count variable which contains the number of
# projects.
array_vars_autocomplete() {
	project_count=${#CROS_WORKON_PROJECT[@]}

	# No project_count is really bad.
	if [[ ${project_count} -eq 0 ]]; then
		die "Must have at least one value in CROS_WORKON_PROJECT"
	fi
	# For one value, defaults will suffice, unless it's blank (likely undefined).
	if [[ ${project_count} -eq 1 ]]; then
		if [[ -z "${CROS_WORKON_PROJECT[@]}" ]]; then
			die "Undefined CROS_WORKON_PROJECT"
		fi
		return
	fi

	local count var
	for var in "${ARRAY_VARIABLES[@]}"; do
		eval count=\${#${var}\[@\]}
		if [[ ${count} -ne ${project_count} ]] && [[ ${count} -ne 1 ]]; then
			die "${var} has ${count} projects. ${project_count} or one default expected."
		fi
		# Invariably, ${project_count} is at least 2 here. All variables also either
		# have all items or the first serves as default (or isn't needed if
		# empty). By looking at the second item, determine if we need to
		# autocomplete.
		local i
		if [[ ${count} -ne ${project_count} ]]; then
			for (( i = 1; i < project_count; ++i )); do
				eval ${var}\[i\]=\${${var}\[0\]}
			done
		fi
		eval einfo "${var}: \${${var}[@]}"
	done
}

# Calculate path where code should be checked out.
# Result passed through global variable "path" to preserve proper array quoting.
get_paths() {
	path=()
	local i
	for (( i = 0; i < project_count; ++i )); do
		path+=( "${CROS_WORKON_REPO}/${CROS_WORKON_PROJECT[i]}" )
	done
}

get_rev() {
	GIT_DIR="$1" git rev-parse HEAD
}

cros-workon_src_unpack() {
	# Sanity check.  We cannot have S set to WORKDIR because if/when we try
	# to check out repos, git will die if it tries to check out into a dir
	# that already exists.  Some packages might try this when out-of-tree
	# builds are enabled, and they'll work fine most of the time because
	# they'll be using a full manifest and will just re-use the existing
	# checkout in src/platform/*.  But if the code detects that it has to
	# make its own checkout, things fall apart.  For out-of-tree builds,
	# the initial $S doesn't even matter because it resets it below to the
	# repo in src/platform/.
	if [[ ${S} == "${WORKDIR}" ]]; then
		die "Sorry, but \$S cannot be set to \$WORKDIR"
	fi

	# Set the default of CROS_WORKON_DESTDIR. This is done here because S is
	# sometimes overridden in ebuilds and we cannot rely on the global state
	# (and therefore ordering of eclass inherits and local ebuild overrides).
	: ${CROS_WORKON_DESTDIR:=${S}}

	# Fix array variables
	array_vars_autocomplete

	# Make sure all CROS_WORKON_DESTDIR are under S.
	local p
	for p in "${CROS_WORKON_DESTDIR[@]}"; do
		if [[ "${p}" != "${S}" && "${p}" != "${S}"/* ]]; then
			die "CROS_WORKON_DESTDIR=${p} must be under S=${S}"
		fi
	done

	local repo=( "${CROS_WORKON_REPO[@]}" )
	local project=( "${CROS_WORKON_PROJECT[@]}" )
	local destdir=( "${CROS_WORKON_DESTDIR[@]}" )
	get_paths

	all_local() {
		local p
		for p in "${path[@]}"; do
			[[ -d ${p} ]] || return 1
		done
		return 0
	}

	local fetched=0
	if all_local; then
		for (( i = 0; i < project_count; ++i )); do
			# Looks like we already have a local copy of all repositories.
			# Let's use these and checkout ${CROS_WORKON_COMMIT}.
			#  -s: For speed, share objects between ${path} and ${S}.
			#  -n: Don't checkout any files from the repository yet. We'll
			#      checkout the source separately.
			#
			# We don't use git clone to checkout the source because the -b
			# option for clone defaults to HEAD if it can't find the
			# revision you requested. On the other hand, git checkout fails
			# if it can't find the revision you requested, so we use that
			# instead.

			# Destination directory. If we have one project, it's simply
			# ${CROS_WORKON_DESTDIR}. More projects either specify an array or go to
			# ${S}/${project}.

			if [[ "${CROS_WORKON_COMMIT[i]}" == "master" ]]; then
				# Since we don't have a CROS_WORKON_COMMIT revision specified,
				# we don't know what revision the ebuild wants. Let's take the
				# version of the code that the user has checked out.
				#
				# This almost replicates the pre-cros-workon behavior, where
				# the code you had in your source tree was used to build
				# things. One difference here, however, is that only committed
				# changes are included.
				#
				# TODO(davidjames): We should fix the preflight buildbot to
				# specify CROS_WORKON_COMMIT for all ebuilds, and update this
				# code path to fail and explain the problem.
				git clone -s "${path[i]}" "${destdir[i]}" || \
					die "Can't clone ${path[i]}."
				: $(( ++fetched ))
			else
				git clone -sn "${path[i]}" "${destdir[i]}" || \
					die "Can't clone ${path[i]}."
				if ! ( cd ${destdir[i]} && git checkout -q ${CROS_WORKON_COMMIT[i]} ) ; then
					ewarn "Cannot run git checkout ${CROS_WORKON_COMMIT[i]} in ${destdir[i]}."
					ewarn "Is ${path[i]} up to date? Try running repo sync."
					rm -rf "${destdir[i]}/.git"
				else
					: $(( ++fetched ))
				fi
			fi
		done
		if [[ ${fetched} -eq ${project_count} ]]; then
			# TODO: Id of all repos?
			# We should run get_rev in destdir[0] because CROS_WORKON_COMMIT
			# is only checked out there. Also, we can't use
			# CROS_WORKON_COMMIT directly because it could be a named or
			# abbreviated ref.
			cros-workon_enforce_subtrees
			return
		else
			die "Could not checkout all projects."
		fi
	else
			die "Not all projects are available locally."
	fi
}

# Enforces subtree restrictions specified by CROS_WORKON_SUBTREE.
cros-workon_enforce_subtrees() {
	local i j p q

	local destdir=( "${CROS_WORKON_DESTDIR[@]}" )

	# Gather the subtrees specified by CROS_WORKON_SUBTREE. All directories
	# and files under those subtrees are not blacklisted.
	local keep_dirs=()
	for (( i = 0; i < project_count; ++i )); do
		if [[ -z "${CROS_WORKON_SUBTREE[i]}" ]]; then
			keep_dirs+=( "${destdir[i]}" )
		else
			for p in ${CROS_WORKON_SUBTREE[i]}; do
				keep_dirs+=( "${destdir[i]}/${p}" )
			done
		fi
	done

	keep_dirs=( $(IFS=$'\n'; LC_ALL=C sort -u <<<"${keep_dirs[*]}") )

	# Ignore overlapping subtrees.
	for (( i = 0; i < ${#keep_dirs[@]}; ++i )); do
		p="${keep_dirs[i]}"
		: $(( j = i + 1 ))
		while (( j < ${#keep_dirs[@]} )); do
			q="${keep_dirs[j]}"
			if [[ "${q}" == "${p}"/* ]]; then
				einfo "Ignoring overlapping CROS_WORKON_SUBTREE: ${q} is under ${p}"
				keep_dirs=( "${keep_dirs[@]:0:j}" "${keep_dirs[@]:$(( j + 1 ))}" )
			else
				: $(( ++j ))
			fi
		done
	done

	# If the directory to keep is $S only, then there is nothing we need to do.
	if [[ "${#keep_dirs[@]}" == 1 && "${keep_dirs}" == "${S}" ]]; then
		return
	fi

	# It is an error to specify a missing file in CROS_WORKON_SUBTREE.
	for p in "${keep_dirs[@]}"; do
		if [[ ! -e "${p}" ]]; then
			die "File specified in CROS_WORKON_SUBTREE is missing: ${p}"
		fi
	done

	# Gather the parent directories of subtrees to use.
	# Those directories are exempted from blacklist because we need them to
	# reach subtrees.
	local keep_parents=()
	for p in "${keep_dirs[@]}"; do
		if [[ "${p}" == "${S}" ]]; then
			continue
		fi
		q="${p%/*}"
		while [[ "${q}" != "${S}" ]]; do
			keep_parents+=( "${q}" )
			q="${q%/*}"
		done
	done

	keep_parents=( $(IFS=$'\n'; LC_ALL=C sort -u <<<"${keep_parents[*]}") )

	# Construct arguments to pass to find(1) to list directories/files to
	# blacklist.
	#
	# The command line built here is tricky, but it does the following
	# during traversal of the filesystem by depth-first order:
	#
	#   1. Do nothing about the root directory ($S). Note that we should not
	#      reach here if there is nothing to blacklist.
	#   2. If the visiting file is a parent directory of a subtree (i.e. in
	#      $keep_parents[@]), then recurse into its contents.
	#   3. If the visiting file is the top directory of a subtree (i.e. in
	#      $keep_dirs[@]), then do not recurse into its contents.
	#   4. Otherwise, blacklist the visiting file, and if it is a directory,
	#      do not recursive into its contents.
	#
	local find_args=( "${S}" -mindepth 1 )
	for p in "${keep_parents[@]}"; do
		find_args+=( ! -path "${p}" )
	done
	find_args+=( -prune )
	for p in "${keep_dirs[@]}"; do
		find_args+=( ! -path "${p}" )
	done

	if [[ "${S}" == "${WORKDIR}"/* ]]; then
		# $S is writable, so just remove blacklisted files.
		find "${find_args[@]}" -exec rm -rf {} +
	else
		# $S is read-only, so use portage sandbox.
		local deny_paths="$(find "${find_args[@]}" -printf '%p:')"
		deny_paths="${deny_paths%:}"
		if [[ -n "${deny_paths}" ]]; then
			adddeny "${deny_paths}"
		fi
	fi
}

cros-workon_pkg_info() {
	print_quoted_array() { printf '"%s"\n' "$@"; }

	array_vars_autocomplete > /dev/null
	get_paths
	CROS_WORKON_SRCDIR=("${path[@]}")

	local val var
	for var in CROS_WORKON_SRCDIR CROS_WORKON_PROJECT CROS_WORKON_COMMIT ; do
		eval val=(\"\${${var}\[@\]}\")
		echo ${var}=\($(print_quoted_array "${val[@]}")\)
	done
}

EXPORT_FUNCTIONS src_unpack pkg_info
