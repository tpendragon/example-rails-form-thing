class GenericAsset < ActiveRecord::Base
  def subject_array
    return self[:subjects].split(",")
  end

  def subject_array=(val)
    self[:subjects] = val.is_a?(Array) ? val.join(",") : val.to_s
  end
end
