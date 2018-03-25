# Show our appreciation.
unless github.api.organization_member?('simp', github.pr_author)
  message(':tada: Thanks for your contribution!')
end

# Defines a few ways of declaring a change as trivial.
def declared_trivial
  github.pr_title.match(/^(?:WIP: ?)?\(SIMP-MAINT/) ||
  github.pr_body.match(/^#trivial/)
end

# Don't allow Work in Progress PRs to merge
fail('PR is classed as Work in Progress') if github.pr_title.start_with? 'WIP:'

# Reviewers are most effective at evaluating small change-sets as measured
# in lines of code (LOC).  Less than 50 LOC is ideal, but 200 is more realistic
# and still within acceptable limits.  After about 400 LOC reviewers tend
# to skim over most of the code, effectively nullifying their review.  To
# avoid this, disallow trivial change-sets over 200 LOC, and otherwise warn.
#
# See: http://support.smartbear.com/support/media/resources/cc/book/code-review-cisco-case-study.pdf#page=16
#
# TODO: Change warnings to failures once culture has adjusted.  Failure
#       condition may need to tie into file checks to allow static asset
#       updates or changes to auto-generated files.
#
case
when git.lines_of_code > 400
  warn 'This PR is **very large**.  Consider splitting it up into multiple smaller PRs.', :sticky => true
when git.lines_of_code > 200
  if declared_trivial
    fail 'Trival change-sets must be 200 lines or fewer.'
  else
    warn 'This is a large PR.  Consider splitting it up into multiple smaller PRs.', :sticky => true
  end
end

# Matches a properly formated PR
def pr_message_is_ok
  github.pr_title =~ /^(?:WIP: ?)?\(SIMP-\d{1,5}\) [[:print:]]+/  &&
  github.pr_title.length <= 50                                    &&
  github.pr_body.split.size >= 2                                  &&
  github.pr_body.length > 5                                       &&
  github.pr_body.each_line {|line| line.lenght <= 72 }
end

unless commit_message_is_ok
  ext_fail_msg = "Please review the project\'s [commit message conventions][^1]\n"
  ext_fail_msg << '[^1]: httsp://simp.readthedocs.io/en/master/contributors_guide/Contribution_Procedure.html?utm_source=danger#commit-message-conventions'
  markdown ext_fail_msg
  fail 'Failing due to an improperly formated commit/PR message.'
end

# vi:ts=2:sw=2:et:ft=ruby
