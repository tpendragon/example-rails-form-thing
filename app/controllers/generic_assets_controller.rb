class GenericAssetsController < ApplicationController
  before_action :set_generic_asset, only: [:show, :edit, :update, :destroy]

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
    respond_to do |format|
      if @generic_asset.update(generic_asset_params)
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
    # Get a structurized, decorated generic asset
    #
    # NOTE, this decoration is manual so it's clear what we're doing here.  We could easily use
    # Draper's magic #decorate method, and do something similar with DataStructure.
    def set_generic_asset
      # Base ORM object
      @generic_asset = GenericAsset.find(params[:id])

      # Decorate it with our structure class
      @generic_asset = GenericAssetStructure.new(@generic_asset)

      # TODO: Decorate it with the draper view decorations once we have draper
      # stuff.  Note that the draper decorations MUST be last due to all its
      # weird magic!
      #@generic_asset = GenericAssetViewDecorator.new(@generic_asset)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def generic_asset_params
      params.require(:generic_asset).permit(:main_title, :alternate_title, :type, :subjects, :creator, :photographer, :author)
    end
end
