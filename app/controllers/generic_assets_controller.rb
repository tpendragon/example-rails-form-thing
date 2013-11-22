require Rails.root.join("lib/data_structure/renderer")

class GenericAssetsController < ApplicationController
  before_action :set_generic_asset, only: [:new, :show, :edit, :update, :destroy]

  # GET /generic_assets
  # GET /generic_assets.json
  def index
    @generic_assets = GenericAsset.all
  end

  # GET /generic_assets/1
  # GET /generic_assets/1.json
  def show
  end

  # GET /generic_assets/new
  def new
    @generic_asset = GenericAsset.new
  end

  # GET /generic_assets/1/edit
  def edit
  end

  # POST /generic_assets
  # POST /generic_assets.json
  def create
    @generic_asset = GenericAsset.new(generic_asset_params)

    respond_to do |format|
      if @generic_asset.save
        format.html { redirect_to @generic_asset, notice: 'Generic asset was successfully created.' }
        format.json { render action: 'show', status: :created, location: @generic_asset }
      else
        format.html { render action: 'new' }
        format.json { render json: @generic_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /generic_assets/1
  # PATCH/PUT /generic_assets/1.json
  def update
    @generic_asset.assign_attributes(generic_asset_params)
    respond_to do |format|
      if @generic_asset.save
        format.html { redirect_to @generic_asset, notice: 'Generic asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @generic_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_assets/1
  # DELETE /generic_assets/1.json
  def destroy
    @generic_asset.destroy
    respond_to do |format|
      format.html { redirect_to generic_assets_url }
      format.json { head :no_content }
    end
  end

  private
    def set_generic_asset
      if (params[:id])
        asset = GenericAsset.find(params[:id])
      else
        asset = GenericAsset.new
      end
      @generic_asset = GenericAssetStructure.new(asset)
      @renderer = DataStructure::Renderer.new(@generic_asset)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def generic_asset_params
      params.require(:generic_asset).permit(
        :subjects,
        :asset_type,
        titles: [:type, :value],
        creators: [:type, :value]
      )
    end
end
