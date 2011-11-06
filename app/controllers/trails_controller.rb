class TrailsController < ApplicationController
  # GET /trails
  # GET /trails.json
  def index
    @trails = Trail.page(params[:page]).per(1)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trails }
    end
  end

  # GET /trails/1
  # GET /trails/1.json
  def show
    @trail = Trail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trail }
    end
  end

  # GET /trails/new
  # GET /trails/new.json
  def new
    @trail = Trail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trail }
    end
  end

  # GET /trails/1/edit
  def edit
    @trail = Trail.find(params[:id])
  end

  # POST /trails
  # POST /trails.json
  def create
    @trail = Trail.new(params[:trail])
	@trail.lat_map = elevation(@trail.longitude_start, @trail.latitude_start, @trail.longitude_end, @trail.latitude_end)
	@trail.gmap = staticmap_uri(@trail.longitude_start + "," + @trail.latitude_start + "|"+ @trail.longitude_end + "," + @trail.latitude_end)
    respond_to do |format|
      if @trail.save
        format.html { redirect_to @trail, notice: 'Trail was successfully created.' }
        format.json { render json: @trail, status: :created, location: @trail }
      else
        format.html { render action: "new" }
        format.json { render json: @trail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /trails/1
  # PUT /trails/1.json
  def update
    @trail = Trail.find(params[:id])

    respond_to do |format|
      if @trail.update_attributes(params[:trail])
        format.html { redirect_to @trail, notice: 'Trail was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @trail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trails/1
  # DELETE /trails/1.json
  def destroy
    @trail = Trail.find(params[:id])
    @trail.destroy

    respond_to do |format|
      format.html { redirect_to trails_url }
      format.json { head :ok }
    end
  end

def elevation(slat, slon, elat, elon)
require 'open-uri'
require 'json'
require 'active_support/core_ext'
require 'net/http'


    @con = slat + "," + slon + "|" + elat + "," + elon
    return getElevation(@con)
end
def getChart(chartData, chartDataScaling="-500,5000", chartType="lc",chartLabel="Elevation in Meters",chartSize="500x160", chartColor="orange", chart_args={})
    chart_args.update({
        cht: chartType,
        chs: chartSize,
        chl: chartLabel,
        chco: chartColor,
        chds: chartDataScaling,
        chxt: 'x,y',
        chxr: '1,-500,5000'
    })
@ELEVATION_BASE_URL = 'http://maps.google.com/maps/api/elevation/json'
@CHART_BASE_URL = 'http://chart.apis.google.com/chart'
    dataString = 't:' + (chartData. * ',')
    chart_args['chd'] = dataString
    chartUrl = @CHART_BASE_URL + '?' + chart_args.to_query
    return chartUrl
end
def getElevation(path="36.578581,-118.291994|36.23998,-116.83171",samples="100",sensor="false", elvtn_args={})
    elvtn_args.update({
        path: path,
        samples: samples,
        sensor: sensor
    })
@ELEVATION_BASE_URL = 'http://maps.google.com/maps/api/elevation/json'
@CHART_BASE_URL = 'http://chart.apis.google.com/chart'
    url = @ELEVATION_BASE_URL + '?' + elvtn_args.to_query
    response = JSON.load(URI.parse(url))
    elevationArray = Array.new
    for result in response['results']
      elevationArray << result["elevation"].round
    end
    return getChart(elevationArray)
end
def staticmap_uri(locations, opts={})
    map_base_url = 'http://maps.googleapis.com/maps/api/staticmap'
    # ?maptype=roadmap
    # &size=640x400
    # &markers=color:green|label:S|latitude,longitude
    # &markers=color:red|label:F|latitude,longitude
    # &sensor=false

    # locations == 49.2710,19.9813|49.2324,19.9817
    locs = locations.split("|")

    map_args = {
      :maptype => "terrain",
      :size => "400x400",
      :markers => [
          "color:green|label:S|#{locs[0]}", "color:red|label:F|#{locs[1]}"
        ],
      :sensor => false
    }.merge!(opts)

    return "#{map_base_url}?#{map_args.to_query}".gsub(/%5B%5D/, "") # remove []

  end
end
