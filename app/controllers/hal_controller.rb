class HalController < ApplicationController
  def searchHal

    client = Savon.client(wsdl: "http://hal.archives-ouvertes.fr/ws/search.php?wsdl")
    articles = []
    begin
      message = { "title" => params[:title], "status" => "all" }
      response = client.call(:exist_on_hal, message: message)

      # message = { "search" => params[:title] }
      # response = client.call(:search, message: message)

    rescue Savon::SOAPFault => error
      fault_code = error.to_hash[:fault][:faultcode]
    end
    if response && response.success?
      @response = response
      # list of article

      @response.body[:exist_on_hal_response][:exist_on_hal_result][:article_struct].each do |a|
        articles.push({title: a[:title], url: a[:url], version: a[:version], identifiant: a[:identifiant]})
      end
    end

    respond_to do |format|
      format.json  { render json: articles }
    end
  end

  def searchArticleOnHal
    client = Savon.client(wsdl: "http://hal.archives-ouvertes.fr/ws/search.php?wsdl")
    identifiant = params[:identifiant]
    version = params[:version]
    begin
      message = { "identifiant" => identifiant, "version" => version }
      response = client.call(:get_article_metadata, message: message)
    rescue Savon::SOAPFault => error
      fault_code = error.to_hash[:fault][:faultcode]
    end
    if response && response.success?
      msg = {}
      resume = ""
      description = ""

      response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_simple][:data_struct].each do |data|
        msg[:title] = data[:meta_value] if data[:meta_name] == "title"
        msg[:datepub] = data[:meta_value] if data[:meta_name] == "datepub"
        description << data[:meta_value] if data[:meta_name] == "abstract"
      end

      response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_aut_lab][:authors][:author_struct].each_with_index do |author,index|
        resume << author[:first_name] + " " + author[:last_name]
        resume << " , " if index != response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_aut_lab][:authors][:author_struct].length
      end

      resume = resume[0..-4]
      msg[:description] = description
      msg[:resume] = resume

      respond_to do |format|
        format.json  { render json: msg }
      end
    end
  end

end