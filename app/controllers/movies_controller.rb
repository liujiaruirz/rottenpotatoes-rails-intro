class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
=begin
Case 1: Starter page:         params: nil, session: nil.
Case 2: New request received: params: not nill. 
                                In this case, if the user hasn't been on info page, session will be nil
                                Note that if session is not nil, We need to overwrite session with 
                                current params status to keep the previous page's records.
                                If we don't, in the following operations, 
                                session will replace the field that is not currently checked.
Case 3: Back from info-page:  params: nil, session: not nil.
                                In this case, apply the operations stored in session.
                                Actually not. For grading purposes, we need RESTful route, that is,
                                redirect to the previous page. 
=end
    @all_ratings = Movie.all_ratings
    @need_to_redirect = false
    # RATING
    if params[:ratings] == nil and session[:ratings] == nil
      # Case 1
      @ratings_to_show = @all_ratings
    end
    if params[:ratings] != nil
      # Case 2
      @ratings_to_show = params[:ratings].keys
      # overwrite session
      session[:ratings] = params[:ratings].keys
      # session.delete(:ratings)
    end
    if params[:ratings] == nil and session[:ratings] != nil
      # Case 3
      @need_to_redirect = true
      @ratings_to_show = session[:ratings] # note that session[:ratings] returns array type, not dict
    end
    @ratings_to_show_hash = Hash[@ratings_to_show.map {|r| [r,1]}]

    # SORT
    if params[:sort] == nil and session[:sort] == nil
      # Case 1
      @order_to_show = ''
    end
    if params[:sort] != nil
      # Case 2
      @order_to_show = params[:sort]
      session[:sort] = params[:sort]
      # session.delete(:sort)
    end
    if params[:sort] == nil and session[:sort] != nil
      # Case 3
      @need_to_redirect = true
      @order_to_show = session[:sort]
    end

    # change header color
    if @order_to_show == 'title'
      @title_header = 'hilite bg-warning'
    elsif @order_to_show == 'release_date'
      @release_date_header = 'hilite bg-warning'
    end

    redirect_to movies_path(ratings: @ratings_to_show_hash, sort: @order_to_show) and return if @need_to_redirect
    @movies = Movie.with_ratings(@ratings_to_show).order(@order_to_show)
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
