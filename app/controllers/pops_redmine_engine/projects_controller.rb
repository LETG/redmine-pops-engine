class ProjectsController < ApplicationController
  # before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :timeline]

  def timeline
    p = @project
    respond_to do |format|
      # msg = { timeline: { headline: "", type: "default", text: "", date: [{startDate: Date.today, endDate: Date.today, headline: p.accronym, text: "<p>"+p.resume+"</p>", tag: "", classname: ""}] } }
      msg = {"timeline":{"headline":"","type":"default","text":"<p>Intro body text goes here, some HTML is ok</p>","date": [{"startDate":"2011,12,10","endDate":"2011,12,11","headline":"POPS","text":"<p>POPS</p>","tag":"","classname":""}]}}
      format.json  { render :json => msg }
    end
  end
end
