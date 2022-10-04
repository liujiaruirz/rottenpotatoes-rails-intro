class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
=begin
Case 1: Starter page:         params: nil, session: nil. 
                                Query with all_ratings and nil sort.
Case 2: New request received: params: not nill (session in this case will always be non nil)
                                Query with the information stored in params.
                                Also, we need to update session. Because once the user go to 
                                movie-info-page, params will be nil but session won't,
                                so we need to keep session up to date with params all the time.
Case 3: Back from info-page:  params: nil, session: not nil.
                                In this case, apply the operations stored in session.
                                Actually not. For grading purposes, we need RESTful route, that is,
                                redirect using the information stored in session and in the new page, 
                                params will not be nil.
=end
    @all_ratings = Movie.all_ratings
    # RATING
    if (params[:ratings] == nil and params[:sort] == nil) and (session[:ratings] == nil and session[:sort] == nil)
      # Case 1
      @ratings_to_show = []
      @movies = Movie.with_ratings(@ratings_to_show)
    elsif params[:ratings] != nil or params[:sort] != nil
      # Case 2
      if params[:ratings] != nil
        @ratings_to_show = params[:ratings].keys
      else 
        @ratings_to_show = session[:ratings]
      end
      # update session
      session[:ratings] = @ratings_to_show
      if params[:sort] == nil
        params[:sort] = session[:sort]
      else
        session[:sort] = params[:sort]
      end
      
      if params[:sort] != nil
        # change header color
        if params[:sort] == 'title'
          @title_header = 'hilite bg-warning'
        elsif params[:sort] == 'release_date'
          @release_date_header = 'hilite bg-warning'
        end
        @movies = Movie.with_ratings(@ratings_to_show).order(params[:sort])
      else
        @movies = Movie.with_ratings(@ratings_to_show)
      end
    elsif (params[:ratings] == nil and params[:sort] == nil) and (session[:ratings] != nil or session[:sort] != nil)
      # Case 3
      if session[:ratings] != nil
        @ratings_to_show = session[:ratings] # note that session[:ratings] returns array type, not dict
      else @ratings_to_show = @all_ratings end
      @ratings_to_show_hash = Hash[@ratings_to_show.map {|r| [r,1]}]
      # change header color
      if session[:sort] != nil
        # if session[:sort] == 'title'
        #   @title_header = 'hilite bg-warning'
        # elsif session[:sort] == 'release_date'
        #   @release_date_header = 'hilite bg-warning'
        redirect_to movies_path(ratings: @ratings_to_show_hash, sort: session[:sort]) and return 
      else
        redirect_to movies_path(ratings: @ratings_to_show_hash) and return 
      end
    end
    

    # # SORT
    # if params[:sort] == nil and session[:sort] == nil
    #   # Case 1
    #   @order_to_show = ''
    # end
    # if params[:sort] != nil
    #   # Case 2
    #   @order_to_show = params[:sort]
    #   session[:sort] = params[:sort]
    #   # session.delete(:sort)
    # end
    # if params[:sort] == nil and session[:sort] != nil
    #   # Case 3
    #   @need_to_redirect = true
    #   @order_to_show = session[:sort]
    # end


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
