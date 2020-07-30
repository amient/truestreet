name = truestreet
version = 1.0.1
binary = $(name).amd64
image = amient/$(name)-amd64:$(version)

all: apply

.PHONY = clean image apply init stop

clean:
	docker rmi $(image) || true
	rm -f $(binary) Dockerfile

image: $(binary) Dockerfile
	docker build -t $(image) ./

Dockerfile: $(binary)
	echo 'FROM scratch\nCOPY $(binary) /$(binary)\nCMD ["/$(binary)"]\n' > Dockerfile

$(binary): *.go **/*.go
	go test ./
	GOOS=linux GOARCH=amd64 go build -ldflags \
	'-w -extldflags "-static"' \
	-o $(binary) ./truestreet.go


# KUBE

init: image
	kubectl run $(name) --image $(image) --restart=Never --expose --port=1760 --service-overrides='{ "spec": { "type": "NodePort" } }'

apply: image
	kubectl set image deployment/$(name) $(name)=$(image)

stop:
	kubectl delete pod $(name) && kubectl delete service $(name) && sleep 3 || true


# docker run --rm truestreet-amd64:1.0.1 /truestreet.amd64 --project heroic-cloud-dev --instance tfgen-spanid-20200730162320698 --db truestreet-db