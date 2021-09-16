class MagicLinkRulesController < ApplicationController

  before_action :require_admin
  layout 'admin'

  def index
    @rules = MagicLinkRule.order("id").all
  end

  def show
    @rule = MagicLinkRule.find(params[:id])
  end

  def new
    @rule = MagicLinkRule.new
  end

  def create
    @rule = MagicLinkRule.new
    @rule.safe_attributes = params[:magic_link_rule]

    if @rule.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_magic_link_rule_successfully_created)
          redirect_to magic_link_rules_path
        }
      end
    else
      respond_to do |format|
        format.html { render :action => :new }
      end
    end
  end

  def edit
    @rule = MagicLinkRule.find(params[:id])
  end

  def update
    @rule = MagicLinkRule.find(params[:id])
    @rule.safe_attributes = params[:magic_link_rule]
    if @rule.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_magic_link_rule_successfully_updated)
          redirect_to magic_link_rules_path
        }
      end
    else
      respond_to do |format|
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @rule = MagicLinkRule.find(params[:id])
    @rule.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_magic_link_rule_successfully_deleted)
        redirect_to(:back)
      }
    end
  end

end
