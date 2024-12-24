# Retrieves the list of generated passwords with attributes and the
# list of sub-folders stored at a simplib::passgen folder.
#
# * Folder specification is only possible in simpkv mode, because only
#   simpkv-enable simplib::passgen supports password identifiers prefixed
#   with a folder path
# * List operation does not recurse into sub-folders.
# * Supports 2 modes:
#
#   * simpkv
#     * Password info is stored in a key/value store and retrieved using simpkv.
#     * Terminates catalog compilation if any simpkv operation fails.
#   * Legacy
#     * Passwordinfo is stored in files on the local file system at
#       `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
#     * Terminates catalog compilation if any password file cannot be accessed
#       by the user.
#
# * To enable simpkv implementation, set `simplib::passgen::simpkv` to `true`
#   in hieradata. When that setting absent or false, legacy mode will be used.
#
Puppet::Functions.create_function(:'simplib::passgen::list') do
  # @param folder Unique `String` to identify the password sub-folder
  #   of the root folder for simplib::passgen
  #   * Only applies when in simpkv mode
  #   * When unset, the list operation will be for the root folder
  #   * Otherwise, must conform to the following:
  #     * Identifier must contain only the following characters:
  #       * a-z
  #       * A-Z
  #       * 0-9
  #       * The following special characters: `._:-/`
  #     * Identifier may not contain '/./' or '/../' sequences.
  #
  # @param simpkv_options
  #   simpkv configuration when in simpkv mode.
  #
  #     * Will be merged with `simpkv::options`.
  #     * All keys are optional.
  #
  # @option simpkv_options [String] 'app_id'
  #   Specifies an application name that can be used to identify which backend
  #   configuration to use via fuzzy name matching, in the absence of the
  #   `backend` option.
  #
  #     * More flexible option than `backend`.
  #     * Useful for grouping together simpkv function calls found in different
  #       catalog resources.
  #     * When specified and the `backend` option is absent, the backend will be
  #       selected preferring a backend in the merged `backends` option whose
  #       name exactly matches the `app_id`, followed by the longest backend
  #       name that matches the beginning of the `app_id`, followed by the
  #       `default` backend.
  #     * When absent and the `backend` option is also absent, this function
  #       will use the `default` backend.
  #
  # @option simpkv_options [String] 'backend'
  #   Definitive name of the backend to use.
  #
  #     * Takes precedence over `app_id`.
  #     * When present, must match a key in the `backends` option of the
  #       merged options Hash or the function will fail.
  #     * When absent in the merged options, this function will select
  #       the backend as described in the `app_id` option.
  #
  # @option simpkv_options [Hash] 'backends'
  #   Hash of backend configurations
  #
  #     * Each backend configuration in the merged options Hash must be
  #       a Hash that has the following keys:
  #
  #       * `type`:  Backend type.
  #       * `id`:  Unique name for the instance of the backend. (Same backend
  #         type can be configured differently).
  #
  #      * Other keys for configuration specific to the backend may also be
  #        present.
  #
  # @option simpkv_options [String] 'environment'
  #   Puppet environment to prepend to keys.
  #
  #     * When set to a non-empty string, it is prepended to the key used in
  #       the backend operation.
  #     * Should only be set to an empty string when the key being accessed is
  #       truly global.
  #     * Defaults to the Puppet environment for the node.
  #
  # @option simpkv_options [Boolean] 'softfail'
  #   Whether to ignore simpkv operation failures.
  #
  #     * When `true`, this function will return a result even when the
  #       operation failed at the backend.
  #     * When `false`, this function will fail when the backend operation
  #       failed.
  #     * Defaults to `false`.
  #
  #
  # @return [Hash]  Hash of results or {} if folder does not exist
  #
  #   * 'keys' = Hash of password information
  #     * 'value'- Hash containing 'password' and 'salt' attributes
  #     * 'metadata' - Hash containing 'complexity' and 'complex_only'
  #        attributes when that information is available; {} otherwise.
  #   * 'folders' = Array of sub-folder names
  #
  # @raise Exception if a simpkv operation fails or any legacy password file
  #   cannot be accessed by the user.
  #
  dispatch :list do
    optional_param 'String', :folder
    optional_param 'Hash',   :simpkv_options
  end

  def list(folder = '/', simpkv_options = { 'app_id' => 'simplib::passgen' })
    use_simpkv = call_function('lookup', 'simplib::passgen::simpkv',
      { 'default_value' => false })
    results = if use_simpkv
                call_function('simplib::passgen::simpkv::list', folder,
                  simpkv_options)
              else
                call_function('simplib::passgen::legacy::list')
              end
    results
  end
end
