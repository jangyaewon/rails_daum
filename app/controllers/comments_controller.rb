class CommentsController < ApplicationController
  def create
    comment = Comment.new
    comment.content = params[:content]
    comment.post_id = params[:id]
    comment.save
    
    redirect_to :back
  end

  def destroy
    comment = Comment.find(params[:id]) #댓글의 id를 가져오는 
    comment.destroy
    
    redirect_to :back
  end
end
