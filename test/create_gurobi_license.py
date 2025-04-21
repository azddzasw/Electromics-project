import os
# Create directory for the license
os.makedirs("../content/licenses", exist_ok=True)

def create_gurobi_license():
    license_content = (
        # Gurobi WLS license file
        # Your credentials are private and should not be shared or copied to public repositories.
        # Visit https://license.gurobi.com/manager/doc/overview for more information.
        WLSACCESSID=5b2b750f-1c22-43fb-9eb9-c40904bb8fd2
        WLSSECRET=08ea2644-9f5f-4ca3-a7f0-a909818adf21
        LICENSEID=2635551
    )
    with open("../content/licenses/gurobi.lic", "w") as f:
        f.write(license_content)
    print("License file created at content/licenses/gurobi.lic")

if __name__ == "__main__":
    create_gurobi_license()