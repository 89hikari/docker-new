FROM ruby:2.6.5-alpine as jekyll-base
RUN mkdir /app
WORKDIR /app
VOLUME /app
ADD . /app
RUN apk add --no-cache build-base gcc bash cmake
RUN gem install bundler -v "~>1.0" && gem install bundler jekyll && bundle install
RUN bundle exec jekyll build
EXPOSE 4000
ENTRYPOINT ["jekyll", "serve"]

FROM jekyll-base as jekyll-build
COPY . /build
WORKDIR /build/app
VOLUME /build/app
RUN bundle exec jekyll build

FROM nginx:stable-alpine as publish
COPY --from=jekyll-build /build/app/_site /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
