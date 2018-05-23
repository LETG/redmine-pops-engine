class HalController < ApplicationController

  def search_hal
    source = "http://api.archives-ouvertes.fr/search/?q=(#{params[:title]})&wt=json&fl=label_s,title_s,uri_s,version_i,docid"
    articles = []
    response = JSON.load(open(URI.encode(source)))
    if response
      article_structs = response["response"]["docs"]
      if article_structs.kind_of?(Array)
        article_structs.each do |a|
          # articles.push({label: a["label_s"],title: a["title_s"][0], url: a["uri_s"], 
          # version: a["version_i"], identifiant: a["docid"]})
          articles.push({title: a["label_s"], url: a["uri_s"], version: a["version_i"], identifiant: a["docid"]})
        end
      end
    end
    respond_to do |format|
      format.json  { render json: articles }
    end
  end

  def search_article_on_hal
    msg = {}
    resume = ""
    description = {}
    source = "http://api.archives-ouvertes.fr/search/?q=docid:(#{params[:identifiant]})&wt=json&fl=title_s,producedDate_tdate,producedDate_s,journalTitle_s,volume_s,issue_s,page_s,authFullName_s"
    response = JSON.load(open(URI.encode(source)))
    
    if response
      data_structs = response["response"]["docs"]
      data_structs.each do |data|
        msg[:title] = data["title_s"]
        msg[:datepub] = (DateTime.iso8601(data["producedDate_tdate"]).strftime("%d/%m/%Y")).to_s
        description[:a] = (data["journalTitle_s"] || "")
        # description[:b] = " " + (data["volume_s"] || "") description[:c] = ", " + data["issue_s"]
        description[:d] = " (" + DateTime.iso8601(data["producedDate_tdate"]).strftime("%d/%m/%Y") + ")" if data["producedDate_tdate"]
        description[:e] = " " + (data["page_s"] || "")
      end
      author_structs = response["response"]["docs"][0]["authFullName_s"]
      if author_structs.kind_of?(Array)
        author_structs.each_with_index do |author,index|
          resume << author
          resume << " , " if index != author_structs.length
        end
      else
        resume << author_structs[0]
      end
      resume = resume[0..-4]
      msg[:description] = description.sort.collect { |a,b| [b] }.flatten.join(" ")
      msg[:resume] = resume
    end
    respond_to do |format|
      format.json { render json: msg }
    end
  end
end
