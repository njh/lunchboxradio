class NetworksController < ApplicationController

  def index
    @networks = Network.find(:all)
  end

  def edit
    @network = Network.find(params[:id])
  end

  def update
    @network = Network.find(params[:id])
    if @network.update_attributes(params[:network])
      flash[:notice] = 'Network settings were successfully updated.'
      redirect_to networks_url
    else
      render :action => :edit
    end
  end

  def new
    @network = Network.new
    render :action => :edit
  end

  def create
    @network = Network.new(params[:network])
    if @network.save  
      flash[:notice] = 'Network was successfully created.'
      redirect_to networks_url
    else
      render :action => :new
    end
  end

end
