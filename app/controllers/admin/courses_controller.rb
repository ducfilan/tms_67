class Admin::CoursesController < ApplicationController

  def index
    @courses = Course.order("created_at DESC")
      .paginate page: params[:page], per_page: Settings.pagination.size
  end

  def new
    @course = Course.new
    @course.build_course_subjects
  end

  def create
    @course = Course.new course_params
    @course.user_id = current_user.id
    if @course.save
      flash[:success] = t "admin.flash.create_course"

      redirect_to admin_course_path @course
    else
      @course.build_course_subjects
      render :new
    end
  end

  def update
    @course = Course.find_by id: params[:id]
    prevent_course_nil

    if params[:type]
      process_start_course
    else
      process_edit_course
    end
  end

  def edit
    @course = Course.find_by id: params[:id]
    prevent_course_nil

    unless @course.nil?
      @course.build_course_subjects @course.subjects
    end
  end

  def show
  end

  def destroy
    @course = Course.find_by id: params[:id]

    if @course.present? && @course.destroy
      flash[:success] = t "admin.courses.mess_delete_success"
    else
      flash[:warning] = t "admin.courses.mess_delete_fail"
    end

    redirect_to admin_courses_path
  end

  private
  def course_params
    params.require(:course).permit :name, :instructions, :status, :start_date,
      :end_date, course_subjects_attributes: [:id, :subject_id, :course_id,
      :status, :_destroy]
  end

  def process_edit_course
    if @course.update_attributes course_params
      flash[:success] = t "admin.flash.edit_course"
      redirect_to admin_course_path @course
    else
      flash[:error] = t "admin.error_messages.error_occurred"
      render :edit
    end
  end

  def process_start_course
    @course.update_attributes status: params[:type].to_i
    render json: {
      htmlText:
        case @course.status
          when Settings.status.started
            ActionController::Base.helpers.
              link_to t("admin.courses.course_item.finish_course"),
                admin_course_path(@course, type: Settings.status.finished),
                data: {
                  confirm: t("admin.courses.course_item.confirm_finish")
                },
               class: "btn btn-danger"
          when Settings.status.finished
            ActionController::Base.helpers.
              button_tag t("admin.courses.course_item.inactive_course"),
                class: "btn btn-default disabled"
        end
    }
  end

  def prevent_course_nil
    if @course.nil?
      flash[:error] = t "admin.error_messages.error_occurred"
      redirect_to admin_courses_path

      true
    end
    false
  end
end
