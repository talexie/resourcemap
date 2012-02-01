class LayersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @show_breadcrumb = true
    add_breadcrumb "Collections", collections_path
    add_breadcrumb collection.name, collection_path(collection)
    add_breadcrumb "Layers", collection_layers_path(collection)
  end

  def create
    layer = layers.new params[:layer]
    layer.save
    render :json => layer
  end

  def update
    layer.fields.destroy_all
    layer.update_attributes params[:layer]
    render :json => layer
  end

  def destroy
    layer.destroy
    head :ok
  end
end
