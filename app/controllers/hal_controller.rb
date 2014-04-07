class HalController < ApplicationController
  def search_hal

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
      article_structs = @response.body[:exist_on_hal_response][:exist_on_hal_result][:article_struct]
      if article_structs.kind_of?(Array)
        article_structs.each do |a|
          articles.push({title: a[:title], url: a[:url], version: a[:version], identifiant: a[:identifiant]})
        end
      else
        articles.push({title: article_structs[:title], url: article_structs[:url], version: article_structs[:version], identifiant: article_structs[:identifiant]})
      end
    end

    respond_to do |format|
      format.json  { render json: articles }
    end
  end

  def search_article_on_hal
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
      description = {}

      response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_simple][:data_struct].each do |data|
        msg[:title] = data[:meta_value] if data[:meta_name] == "title"
        msg[:datepub] = data[:meta_value] if data[:meta_name] == "datepub"

        description[:a] = data[:meta_value] if data[:meta_name] == "journal"
        description[:b] = " " + data[:meta_value] if data[:meta_name] == "volume"
        description[:c] = ", " + data[:meta_value] if data[:meta_name] == "issue"
        description[:d] = " (" + data[:meta_value] + ")" if data[:meta_name] == "datepub"
        description[:e] = " " + data[:meta_value] if data[:meta_name] == "page"
      end

      author_structs = response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_aut_lab][:authors][:author_struct]

      if author_structs.kind_of?(Array)
        author_structs.each_with_index do |author,index|
          resume << author[:first_name] + " " + author[:last_name]
          resume << " , " if index != response.body[:get_article_metadata_response][:get_article_metadata_result][:meta_aut_lab][:authors][:author_struct].length
        end
      else
        resume << author_structs[:first_name] + " " + author_structs[:last_name]
      end

      resume = resume[0..-4]
      msg[:description] = description.sort.collect { |a,b| [b] }.flatten.join(" ")
      msg[:resume] = resume

      respond_to do |format|
        format.json  { render json: msg }
      end
    end
  end

end