IMAGE    = imthai/qbittorrent-filebot
WORKFLOW = build-and-push.yml

test:
	docker build --platform linux/amd64 -t $(IMAGE):test .
	docker push $(IMAGE):test

ci:
	git push
	gh workflow run $(WORKFLOW)

.PHONY: test ci
