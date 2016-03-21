class TestitRelationsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize
  before_filter :find_issue
  before_filter :find_setting


  # before_filter :find_issue, :authorize, :only => [:index, :create]
  before_filter :find_relation, :only => [:show, :destroy]



  helper :testit_sort
  helper :testit_queries

  #
  include TestitSortHelper
  include TestitQueriesHelper
  #
  # GET display a list of all events
  # /photos
  def index
      @testit_relations = @issue.testit_relations
      respond_to do | format | 
          format.html { render :layout => !request.xhr? }
      end
  end
  # GET display a specific event
  # /photos/:id
  def show
      raise Unauthorized unless @testit_relation.visible?

      @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }

      respond_to do | format | 
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/show.hook' }
      end
  end

  # POST create a new event
  # /photos
  def create
      issue_tracker_type = @setting.tracker_type_of(@issue)
      # @testit_relations = @issue.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
      find_issues
      # TODO start transaction
      saved = true
      @issues.each { | issue_to | 
          testit_relation = Testit::Relation.new(:relation_type => params[:relation])
          testit_relation.issue_from = @issue
          testit_relation.issue_to = issue_to
          testit_relation.init_journals(User.current)
          x = testit_relation.save
          p "RELATION => #{testit_relation} -> #{x}"
          saved = x && saved
      }
      # TODO end transaction
     
      #  if params[:relation] && m = params[:relation][:issue_to_id].to_s.strip.match(/^#?(\d+)$/)
      #      @testit_relation.issue_to = Issue.visible.find_by_id(m[1].to_i)
      #  end
      #  @testit_relation.init_journals(User.current)
      #  saved = @testit_relation.save
      #
      respond_to do |format|
          format.js {
              @testit_relations = @issue.reload.testit_relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
          }
          format.api {
              if saved
                  render :action => 'show', :status => :created, :location => relation_url(@relation)
              else
                  render_validation_errors(@relation)
              end
          }
      end
  end
  # DELETE delete a specific event
  # /photos/:id
  def destroy
      raise Unauthorized unless @testit_relation.deletable?
      @testit_relation.init_journals(User.current)
      @testit_relation.destroy

      respond_to do |format|
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/show', 
                        :locals => {
              :title => l(:title_testit_tests),
              :tracker_type => issue_tracker_type
          }}
          format.js
      end

  end
  #
  # testit relations
  # as views sao uma lista para piq piq piq
  #
  # GET return an HTML form for creating a new event
  # /photos/new
  # add test_suite relation to test_case
  def new_ts
      retrieve_query_for(Testit::Setting::TestSuiteTrackerType)
      calc_relation_type(:new_ts) 
      @testit_relation = Testit::Relation.new(:relation_type => @relation_type)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_to_test_suite)} }
      end
  end
  # add test_run relation to test_case
  def new_tr
      retrieve_query_for(Testit::Setting::TestRunTrackerType)
      calc_relation_type(:new_tr) 
      @testit_relation = Testit::Relation.new(:relation_type => @relation_type)

      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_test_run)} }
      end
  end
  # add test_csse relation to test_plan / test_suite
  def new_tc
      retrieve_query_for(Testit::Setting::TestCaseTrackerType)
      calc_relation_type(:new_tc) 
      @testit_relation = Testit::Relation.new(:relation_type => @relation_type)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_test_case)} }
      end
  end
  # add test_plan relation to test_case
  def new_tp
      retrieve_query_for(Testit::Setting::TestPlanTrackerType)
      calc_relation_type(:new_tp) 
      @testit_relation = Testit::Relation.new(:relation_type => @relation_type)
      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_to_test_plan)} }
      end
  end
  # add reuirement relation to test_case
  def new_req
      retrieve_query_for(Testit::Setting::RequirementTrackerType)
      calc_relation_type(:new_req) 
      @testit_relation = Testit::Relation.new(:relation_type => @relation_type)

      respond_to do | format |
          format.html { render :layout => !request.xhr?, :partial => 'testit_relations/new', 
                        :locals => {:title => l(:title_add_requirement)} }
      end
  end
  def retrieve_query_for(*testit_tracker_types)
      @query = Testit::TestitQuery.new(:name => "_")
      @query.project = @project
      @query.build_trackers_filters_for(*testit_tracker_types)
      @query.build_from_params(params)
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      if @query.valid?
          @limit = per_page_option
          @issue_count = @query.issue_count
          @issue_pages = Redmine::Pagination::Paginator.new @issue_count, @limit, params['page']
          @offset ||= @issue_pages.offset
          @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                  :order => sort_clause,
                                  :offset => @offset,
                                  :limit => @limit)
          @issue_count_by_group = @query.issue_count_by_group
      end
  end

  def find_issues
      @issues = Issue.find(params[:ids])
      @project = @issue.project
  rescue ActiveRecord::RecordNotFound
      render_404
  end
  def find_issue
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
  rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_relation
      @testit_relation = Testit::Relation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      render_404
  end


  def find_project
      begin
          @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end

  def find_setting
      begin
          @setting = Testit::Setting.find_by(:project_id => @project)
      rescue ActiveRecord::RecordNotFound
          render_404
      end
  end

  def find_issue
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
  rescue ActiveRecord::RecordNotFound
      render_404
  end

  def calc_relation_type(op)
      @op =op
      issue_tracker_type = @setting.tracker_type_of(@issue)
      case issue_tracker_type
      when Testit::Setting::RequirementTrackerType
          case op
          when :new_tc
              @relation_type = Testit::Relation::TYPE_REQ_HAS_TC
          end
      when Testit::Setting::TestCaseTrackerType
          case op
          when :new_ts
              @relation_type = Testit::Relation::TYPE_TC_PART_OF_TS
          when :new_tr
              @relation_type = Testit::Relation::TYPE_TC_HAS_TR
          when :new_tp
              @relation_type = Testit::Relation::TYPE_TC_PART_OF_TP
          when :new_req
              @relation_type = Testit::Relation::TYPE_TC_PART_OF_REQ
          end
      when Testit::Setting::TestSuiteTrackerType
          case op
          when :new_tc
              @relation_type = Testit::Relation::TYPE_TS_HAS_TC
          end
      when Testit::Setting::TestPlanTrackerType
          case op
          when :new_tc
              @relation_type = Testit::Relation::TYPE_TP_HAS_TC
          end
      when Testit::Setting::TestRunTrackerType
          case op
          when :new_tc
              @relation_type = Testit::Relation::TYPE_TR_PART_OF_TC
          end
      end
  end



end

