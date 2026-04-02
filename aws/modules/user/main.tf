resource "aws_iam_user" "trainee" {
  name = var.trainee_username
  tags = var.tags
}

resource "aws_iam_user_login_profile" "trainee_password" {
  user                    = aws_iam_user.trainee.name
  password_length         = 18
  password_reset_required = false
}

resource "aws_iam_access_key" "trainee" {
  user = aws_iam_user.trainee.name
}

resource "aws_iam_user_group_membership" "trainee" {
  user = aws_iam_user.trainee.name

  groups = [
    var.trainee_group_name,
  ]
}
