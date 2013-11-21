class GenericAsset < ActiveRecord::Base
  # Deserializes data from the given field by splitting on commas - obviously you wouldn't likely
  # do this in a real application!
  def get_array(field)
    return [] unless self[field]
    return self[field].split(",")
  end

  # Serializes data from an array of values into a comma-delimited string.  Allows for non-array
  # values just in case I can't get the API to force that in.
  def set_array(field, values)
    unless values.is_a?(Array)
      return self[field] = values
    end

    return self[field] = values.join(",")
  end

  # NOTE: in a real app, the get/set functions and all the crazy functions below would get really
  # ugly fast.  It would probably make sense to extract into some kind of acts_as_serializable
  # mixin or something to avoid all this redundant code.

  def main_titles; get_array(:main_title); end
  def main_titles=(values); set_array(:main_title, values); end
  def alt_titles; get_array(:alt_title); end
  def alt_titles=(values); set_array(:alt_title, values); end
  def parallel_titles; get_array(:parallel_title); end
  def parallel_titles=(values); set_array(:parallel_title, values); end
  def series; get_array(:series); end
  def series=(values); set_array(:series, values); end

  # Why creator_array instead of creators?  Because the *attribute* is "creators".  If the subtype
  # is also "creators", stack overflows ensue.
  def creator_array; get_array(:creator); end
  def creator_array=(values); set_array(:creator, values); end
  def photographers; get_array(:photographer); end
  def photographers=(values); set_array(:photographer, values); end
  def authors; get_array(:author); end
  def authors=(values); set_array(:author, values); end

  def subject_array; get_array(:subjects); end
  def subject_array=(values); set_array(:subjects, values); end

  def admin_replaces_array; get_array(:admin_replaces); end
  def admin_replaces_array=(values); set_array(:admin_replaces, values); end
  def original_full_asset_path_array; get_array(:original_full_asset_path); end
  def original_full_asset_path_array=(values); set_array(:original_full_asset_path, values); end
  def admin_conversion_spec_array; get_array(:admin_conversion_spec); end
  def admin_conversion_spec_array=(values); set_array(:admin_conversion_spec, values); end
end
