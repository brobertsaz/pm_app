class CommentChannel < ApplicationCable::Channel
  def subscribed
    project_id = params['project_id']
    commentable_type = params['commentable_type']
    commentable_id = params['commentable_id']

    if project_id.present? && commentable_type.present? && commentable_id.present?
      @project = Project.find_by(id: project_id)
      @commentable_type = commentable_type
      @commentable_id = commentable_id

      if @project.present?
        stream_for @project
        transmit(
          type: 'subscription_confirmed',
          message: "Connected to #{commentable_type} ##{commentable_id} comments",
          project_id: @project.id,
          timestamp: Time.current.iso8601
        )
      else
        reject
      end
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # Called when a new comment is created
  def self.broadcast_comment_created(project, comment)
    broadcast_to project, {
      type: 'comment_created',
      comment: CommentSerializer.new(comment).as_json,
      project_id: project.id,
      commentable_type: comment.commentable_type,
      commentable_id: comment.commentable_id,
      timestamp: Time.current.iso8601
    }
  end

  # Called when a comment is updated
  def self.broadcast_comment_updated(project, comment)
    broadcast_to project, {
      type: 'comment_updated',
      comment: CommentSerializer.new(comment).as_json,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end

  # Called when a comment is deleted
  def self.broadcast_comment_deleted(project, comment)
    broadcast_to project, {
      type: 'comment_deleted',
      comment_id: comment.id,
      commentable_type: comment.commentable_type,
      commentable_id: comment.commentable_id,
      project_id: project.id,
      timestamp: Time.current.iso8601
    }
  end
end
