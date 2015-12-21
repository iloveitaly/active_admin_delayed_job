ActiveAdmin.register Delayed::Job, :as => "Background Job" do
  menu label: "Background Jobs",  title: 'Background Jobs', parent: "Dashboard"

  actions :index, :show, :update, :edit, :destroy

  filter :queue

  batch_action 'Retry' do |selection|
    Delayed::Job.find(selection).each do |job|
      job.retry!
    end

    redirect_to self.send("#{ActiveAdmin.application.default_namespace}_background_jobs_path"), notice: "Retrying Jobs"
  end

  member_action :retry, method: :post do
    job = Delayed::Job.find(params[:id])
    job.retry!

    # TODO there has got to be a better way to get the helper prefix
    redirect_to self.send("#{ActiveAdmin.application.default_namespace}_background_jobs_path"), notice: "Retrying Job"
  end

  action_item :retry_job, only: :show do
    link_to("Retry Job", self.send("retry_#{ActiveAdmin.application.default_namespace}_background_job_path", resource), method: :post)
  end

  index do     
    selectable_column                        
    column :id 
    column :failed_at
    column :attempts
    
    column :status do |job|
      case job.state
      when 'failed'
        status_tag "Failed:", :error 
        span "#{job.last_error[0..100]}" 
      when 'running'
        status_tag "Running", :warning
        span "for #{time_ago_in_words(job.locked_at)} @ #{job.locked_by}"   
      when 'scheduled'
        status_tag "Scheduled", :ok
        span "for #{time_ago_in_words(job.run_at)} from now" 
      else
        status_tag "Queued" 
        span "for #{time_ago_in_words(job.created_at)}" 
      end
      
    end

    actions defaults: true do |job|
      link_to("Retry Job", self.send("retry_#{ActiveAdmin.application.default_namespace}_background_job_path", job), method: :post)
    end              
  end

  show do |job|
    # customize handler + last_error fields
    attributes_table *(default_attribute_table_rows - [:handler, :last_error]) do
      row(:handler) { content_tag(:pre, job.handler) rescue "" }
      row(:last_error) { content_tag(:pre, job.last_error) rescue "" }
    end
  end

  # https://github.com/activeadmin/activeadmin/blob/9cfc45330e5ad31977b3ac7b2ccc1f8d6146c73f/lib/active_admin/views/pages/form.rb
  form do |f|
    f.inputs do
      f.input :handler
    end

    f.actions
  end

  member_action :update, method: :put do
    resource.update_attribute(:handler, params[:background_job]["handler"])

    redirect_to({ action: 'index' })
  end

end
