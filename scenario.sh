#for VARIABLE in 1 .. 2
#do
#   ./updater.sh ./apps/guestbook/deployment.yaml "0.1" "0.2"
#   ./updater.sh ./apps/guestbook2/deployment.yaml "0.1" "0.2"
#   ./updater.sh ./apps/guestbook3/deployment.yaml "0.1" "0.2"
#
#   sleep 30
#
#   ./updater.sh ./apps/guestbook/deployment.yaml "0.2" "0.1"
#   ./updater.sh ./apps/guestbook2/deployment.yaml "0.2" "0.1"
#   ./updater.sh ./apps/guestbook3/deployment.yaml "0.2" "0.1"
#
#   sleep 30
#done
#

for VARIABLE in 1 .. 50
do
   ./updater.sh ./helm-apps/helm-guestbook/deployment.yaml "0.1" "0.2"
   ./updater.sh ./helm-apps/helm-guestbook2/deployment.yaml "0.1" "0.2"
   ./updater.sh ./helm-apps/helm-guestbook3/deployment.yaml "0.1" "0.2"

   sleep 30

   ./updater.sh ./helm-apps/helm-guestbook/deployment.yaml "0.2" "0.1"
   ./updater.sh ./helm-apps/helm-guestbook2/deployment.yaml "0.2" "0.1"
   ./updater.sh ./helm-apps/helm-guestbook3/deployment.yaml "0.2" "0.1"

   sleep 30
done




# ./updater.sh ./apps/guestbook/deployment.yaml "0.3" "0.2" "0.1"
