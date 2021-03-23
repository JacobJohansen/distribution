FROM public.ecr.aws/lambda/provided:al2 as build
# install compiler
RUN yum install -y golang
RUN go env -w GOPROXY=direct
# cache dependencies
ADD go.mod go.sum ./
RUN go mod download
# build
ADD . .
RUN go build -o /build/distribution/registry
# copy artifacts to a clean image
FROM public.ecr.aws/lambda/provided:al2

COPY ./cmd/registry/config-dev.yml /etc/docker/registry/config.yml
COPY --from=build /build/distribution/registry /bin/registry
VOLUME ["/var/lib/registry"]
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]