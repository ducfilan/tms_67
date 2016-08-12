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
  end

  def show
  end

  def destroy
  end

  private
  def course_params
    params.require(:course).permit :name, :instructions, :status, :start_date,
      :end_date, course_subjects_attributes: [:id, :subject_id, :course_id,
      :status, :_destroy]
  end
end
