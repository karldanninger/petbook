class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end

    @microposts = Micropost.find_by_sql("SELECT * FROM microposts ORDER BY updated_at DESC LIMIT 4")
  end

  def help
  end

  def about
  end

  def contact
  end
end
