EmojiCharades::Application.routes.draw do
  resources :user
  resources :game do resources :turn end
end
