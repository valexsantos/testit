class TestitTestsController < ApplicationController
  unloadable

  before_filter :find_project 
  before_filter :find_setting
  before_filter :find_issue, :only => [:show, :edit, :update, :add_ts, :add_tr]
  before_filter :find_issues, :only => [:destroy]
  before_filter :authorize, :except => [:index, :new, :create, :add_ts, :add_tr]

  before_filter :build_new_issue_from_params, :only => [:new, :create]

  helper :projects
  helper :custom_fields
  helper :journals
  helper :projects
  helper :custom_fields
  helper :watchers
  helper :attachments
  helper :repositories
  helper :timelog
  helper :issue_relations
  #
  helper :testit
  helper :testit_sort
  helper :testit_queries
  helper :testit_issues
  helper :testit_tests

  include TestitIssuesAbstractController
  include TestitTestsHelper
  include TestitHelper

  def the_query
      {:key=>:test_query, :klass => Testit::TestsQuery}
  end

  # GET display a list of all events
  # /photos
  def index
      super
      respond_to do | format |
         if params[:table]
             format.html{ render :partial=> "testit_common/issue_list", :layout => !request.xhr?, 
                          :locals => {:query => @query, :issues => @issues,
                                      :title => l(:label_test_case_plural),
                                      :available_formats => ['Atom', 'CSV', 'PDF'],
                                      :query_form_id => 'query-form',
                                      :query_submit_url => partial_query_common_options,
                                      :query_list_dest_id => 'issue-list',
                                      :table_form_id => 'table-issue-list',
                                      :table_show_select_all => false}
             }
         else 
             format.html { render :layout => !request.xhr? }
         end
      end
  end
  # GET display a specific event
  # /photos/:id
  def show
      @settings = Testit::Setting.find_by(:project_id => @project)
      super
      respond_to do | format | 
          format.html { 
            # TODO retrieve_previous_and_next_issue_ids
            render :layout => !request.xhr?
          }
          format.pdf  {
              send_file_headers! :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf"
          }
      end
  end

  # GET return an HTML form for creating a new event
  # /photos/new
  def new
      super
      @tracker = @setting.tracker(Testit::Setting::TestCaseTrackerType)
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
          format.js
      end
  end

  # GET return an HTML form for editing an event
  # /photos/:id/edit
  def edit
      super
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
          format.js
      end
  end

  # POST create a new event
  # /photos
  def create

      unless User.current.allowed_to?(:add_issues, @issue.project, :global => true)
          raise ::Unauthorized
      end
      # create_new_issue_from param
      # 
      # @issue = new TestCase
      
      ActiveRecord::Base.transaction do

          @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
          @issue.save!

          # 
          # create new TestRun issue
          #
          @test_run = Issue.new
          @test_run.project = @project
          @test_run.tracker = @setting.tracker(Testit::Setting::TestRunTrackerType)
          @test_run.subject = @issue.subject
          @test_run.description = "Execution task for #{@issue.tracker.name} ##{@issue.id}: #{@issue.subject}"
          @test_run.author ||= User.current
          @test_run.start_date ||= Date.today if Setting.default_issue_start_date_to_creation_date?
          @test_run.save!

          #
          # add the relation
          #
          @relation_type = Testit::Relation::TYPE_TC_HAS_TR
          @testit_relation = Testit::Relation.new(:relation_type => @relation_type)
          @testit_relation.issue_from = @issue
          @testit_relation.issue_to = @test_run
          @testit_relation.init_journals(User.current)
          @testit_relation.save
          flash[:notice] = l(:notice_test_case_created)
          # redirect_to :controller=> :testit, :action => :index, :project_id => @project
          redirect_to  :controller => :testit_tests, :action => :show, :project_id => @project, :id => @issue
      end
  end
  # PUT update a specific event
  # /photos/:id
  def update
      if super
          render_attachment_warning_if_needed(@issue)
          flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?
          redirect_to  :controller => :testit_tests, :action => :show, :project_id => @project, :id => @issue
      else
          redirect_to :action => :edit, :project_id => @project
      end
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
  end

end

