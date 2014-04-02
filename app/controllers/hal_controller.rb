class HalController < ApplicationController
  def searchHal
    client = Savon.client(wsdl: "http://hal.archives-ouvertes.fr/ws/search.php?wsdl")
    articles = []
    begin
      message = { "title" => params[:title], "status" => "all" }
      response = client.call(:exist_on_hal, message: message)
    rescue Savon::SOAPFault => error
      fault_code = error.to_hash[:fault][:faultcode]
    end
    if response && response.success?
      @response = response
      # list of article

      @response.body[:exist_on_hal_response][:exist_on_hal_result][:article_struct].each do |a|
        articles.push({title: a[:title], url: a[:url], version: a[:version]})
      end
    end

    respond_to do |format|
      format.json  { render :json => articles }
    end
  end
end