#!/bin/sh

# failsafe
set -eEuo pipefail

# list all images and count
echo "Counting image history"
gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags  | grep -v DIGEST | wc -l

# demote 'oldest' to ''
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags='oldest'" --format='get(DIGEST)'); do
  echo "Demoting 'oldest' -> '': " + $DIGEST
  gcloud artifacts docker tags delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):oldest"
done

# demote 'older' to 'oldest'
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags='older'" --format='get(DIGEST)'); do
  echo "Demoting 'older' -> 'oldest': " + $DIGEST
  gcloud artifacts docker tags add -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE)@${DIGEST}" "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):oldest"
  gcloud artifacts docker tags delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):older"
done

# demote 'old' to 'older'
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags='old'" --format='get(DIGEST)'); do
  echo "Demoting 'old' -> 'older': " + $DIGEST
  gcloud artifacts docker tags add -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE)@${DIGEST}" "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):older"
  gcloud artifacts docker tags delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):old"
done

# demote 'live' to 'old'
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags='live'" --format='get(DIGEST)'); do
  echo "Demoting 'live' -> 'old': " + $DIGEST
  gcloud artifacts docker tags add -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE)@${DIGEST}" "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):old"
  gcloud artifacts docker tags delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):live"
done

# update 'staged' to 'live'
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags='staged'" --format='get(DIGEST)'); do
  echo "Updating 'staged' -> 'live': " + $DIGEST
  gcloud artifacts docker tags add -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE)@${DIGEST}" "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):live"
  gcloud artifacts docker tags delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE):staged"
done

# delete untagged images
for DIGEST in $(gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags --filter="tags=''" --format='get(DIGEST)'); do
  echo "Deleting untagged image: " + $DIGEST
  gcloud artifacts docker images delete -q "$(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE)@${DIGEST}"
done

# list all images and count
echo "Counting image history"
gcloud artifacts docker images list $(cat ./REGION)-docker.pkg.dev/$(cat ./PROJECT_ID)/$(cat ./ARTIFACT_REPO)/$(cat ./RUN_SERVICE) --include-tags  | grep -v DIGEST | wc -l