# Flask App on AWS EKS

#פרויקט זה מדגים תהליך ci/cd מלא עבור אפליקציות Flask שנפרסת על Amazon EKS באמצעות Terraform, Docker, ECR ו-Helm.

## Main tools

- **Flask** - אפליקציית Python בסיסית.
- **Docker** - קונטיינריציה של האפליקציה.
- **Amazon ECR** - מאגר תמונות Docker.
- **Terraform** - יצירת תשתית(VPC, EKS, ECR..)
- **HELM** - פריסת kubernetes על EKS
- **GitHub Action** - אוטומציה של תהליך CI/CD

---

## folder structure
flask-app/app - קוד בFlask ו-Dockerfile
flask-app/infra - קבצי Terraform לתשתית
flask-app/helm/flask-app - לפריסה 
.github/workflows - להרצה אוטומטית של האפלקצייה המלאה 

## keys
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
