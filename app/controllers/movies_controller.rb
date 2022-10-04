class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @need_to_redirect = false
    # RATING
    if params[:ratings] == nil and session[:ratings] == nil
      # new page
      @ratings_to_show = []
    end
    if params[:ratings] != nil
      # new request received
      @ratings_to_show = params[:ratings].keys
      # overwrite session
      session[:ratings] = @ratings_to_show
    end
    if params[:ratings] == nil and session[:ratings] != nil
      # back from more-info page
      @need_to_redirect = true
      @ratings_to_show = session[:ratings] # note that session[:ratings] returns array type, not dict
    end
    @ratings_to_show_hash = Hash[@ratings_to_show.map {|r| [r,1]}]
  
    # SORT
    if params[:sort] == nil and session[:sort] == nil
      @order_to_show = ''
    elsif params[:sort] != nil
      @order_to_show = params[:sort]
      session[:sort] = params[:sort]
    elsif params[:sort] == nil and session[:sort] != nil
      # redirect to the previous case
      @order_to_show = session[:sort]
      @need_to_redirect = true
    end

    # change header color
    if @order_to_show == 'title'
      @title_header = 'hilite bg-warning'
    elsif @order_to_show == 'release_date'
      @release_date_header = 'hilite bg-warning'
    end

    if @need_to_redirect
      redirect_to movies_path(ratings: @ratings_to_show_hash, sort: @order_to_show)
    else
      @movies = Movie.with_ratings(@ratings_to_show).order(@order_to_show)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
