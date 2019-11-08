class AcceptHelper
  include Redmine::I18n
  
  def self.generate_accept_button (issue)
     # accepting closed tickets should not be possible
     status_id =  issue[:status_id]
     issue_status = IssueStatus.find(status_id)
     if issue_status[:is_closed] == true
       return ""
     end

     accept_status_name = Setting.plugin_accept[:accept_status]
     individual_status = Setting.plugin_accept[:accept_individual_status]
     # if accept_status is defined per tracker, use the specific accept_status
     if individual_status == 'individual_status_for_each_tracker'
       tracker_id = Tracker.where(id: issue.tracker_id)[0].id
       accept_status_name = Setting.plugin_accept['accept_status_' + tracker_id.to_s]
     end
     accept_status =  IssueStatus.where(name: accept_status_name)

     # generate the button code - since there appears to be no explicit hook for the menu buttons, use js to insert the button
     if accept_status.empty?
       accept_id = IssueStatus.first[:id].to_s
     else
       accept_id = accept_status[0][:id].to_s
     end
     user_id = User.current.id.to_s

     html = '<script>
     var isStatusPresent = $("#issue_status_id>option[value=' + accept_id + ']").length > 0;
     var isAssigneePresent = $("#issue_assigned_to_id>option[value=' + user_id  + ']").length > 0;
     var isNotAccepted = $("#issue_status_id").val() != ' + accept_id + ';
      
     if (isStatusPresent && isAssigneePresent && isNotAccepted) {
      var button = $("<a class=\"icon icon-accept\" onclick=\"acceptTicket()\">'+ l(:accept_label) +'</a>");
      $("#content .contextual:first").append(button);
     }

     function acceptTicket() {
      $("#issue_status_id").val("' + accept_id+ '");
      $("#issue_assigned_to_id").val(' + user_id + ');
      $("#update input[type=submit]").click();
      }
      </script>'

      return html
  end
end
