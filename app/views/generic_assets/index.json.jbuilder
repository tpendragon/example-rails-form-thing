json.array!(@generic_assets) do |generic_asset|
  json.extract! generic_asset, :main_title, :alternate_title, :type, :subjects, :creator, :photographer, :author
  json.url generic_asset_url(generic_asset, format: :json)
end
