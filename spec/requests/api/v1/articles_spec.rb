RSpec.describe Api::V1::ArticlesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }
  let(:not_headers) { {HTTP_ACCEPT: "application/json"} }

  describe "GET /api/v1/articles" do
    before do
      5.times { FactoryBot.create(:article) }
    end

    it "returns a collection of articles" do
      get "/api/v1/articles", headers: headers
      expect(json_response.count).to eq 5
    end

    it "returns 200 response" do
      get "/api/v1/articles", headers: headers
      expect(response.status).to eq 200
    end
    
    it "has a category key in the response" do
      get "/api/v1/articles", headers: headers

      articles = Article.all
      
      articles.each do |article|
        expect(json_response[articles.index(article)]).to include('category')
        expect(json_response[articles.index(article)]['category'].length).to eq 2
        expect(json_response[articles.index(article)]['category']).to be_truthy
      end
    end
    
    it "has a reviews key in the response" do

      articles = Article.all

      articles.each do |article|
        FactoryBot.create(:review, article_id: article.id, score: 10)

        get "/api/v1/articles", headers: headers
        expect(json_response[articles.index(article)]).to include('reviews')
        expect(json_response[articles.index(article)]['reviews'][0].length).to eq 4
        expect(json_response[articles.index(article)]['reviews']).to be_truthy
      end
    end
  end

  describe "GET /api/v1/articles/id" do
    let(:article) { FactoryBot.create(:article)}

    before do
      get "/api/v1/articles/"+"#{article.id}", headers: headers
    end

    it "returns a specific article" do
      expect(json_response["id"]).to eq article.id
    end

    it "returns 200 response" do
      expect(response.status).to eq 200
    end

    it "does not return a full article if user is not logged in" do
      get "/api/v1/articles/"+"#{article.id}", headers: not_headers
      expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
    end
  end

  describe "POST /api/v1/articles" do

    describe "successfully" do
      let(:category) { FactoryBot.create(:category) }
  
      before do
        post "/api/v1/articles", params: {
          article: {
            title: 'Gothenburg is great',
            ingress: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris',
            body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris',
            image: 'https://assets.craftacademy.se/images/people/students_group.png',
            written_by: 'Steffe Karlberg',
            category_id: category.id,
            country: "Sweden",
            city: "Gothenburg"
            }
        }, headers: headers
        end

        it "creates an article entry" do
          expect(json_response["message"]).to eq "Successfully created"
          expect(response.status).to eq 200
        end

        it "sends back into the response the newly created article information" do
          article = Article.last
          expect(json_response["article_id"]).to eq article.id
        end  
    end
  end

  describe "POST /api/v1/articles" do
    describe "unsuccessfully" do

      it "can not be created without all fields filled in" do
        post "/api/v1/articles", params: {
          article: {
            title: "Stockolm is not too bad",
            written_by: "Steffe Karlberg",
          }
        }, headers: headers

        expect(json_response['error']).to eq ["Category must exist", "Ingress can't be blank", "Ingress is too short (minimum is 50 characters)", "Body can't be blank", "Body is too short (minimum is 1000 characters)", "Image can't be blank", "Category can't be blank", "Country can't be blank", "City can't be blank"]

        expect(response.status).to eq 422
      end

      it "can not be created if user is not logged in" do
        post "/api/v1/articles", headers: not_headers
        expect(json_response["errors"]).to eq ["You need to sign in or sign up before continuing."]
      end
    end
  end
end
