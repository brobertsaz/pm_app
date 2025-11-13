class CommentSerializer
  def initialize(comment)
    @comment = comment
  end

  def as_json(*args)
    {
      id: @comment.id,
      body: @comment.body,
      user: {
        id: @comment.user&.id,
        email: @comment.user&.email,
        name: @comment.user&.full_name
      },
      commentable_type: @comment.commentable_type,
      commentable_id: @comment.commentable_id,
      created_at: @comment.created_at&.iso8601,
      updated_at: @comment.updated_at&.iso8601
    }
  end
end
