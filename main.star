# This Kurtosis package spins up a local Celestia based on rollkit 
# https://github.com/rollkit/local-celestia-devnet


def run(plan):
    # config
    env_vars = {}
    env_vars["CELESTIA_NAMESPACE"] = "lazy_namespace"

    # celestia-app
    validator_grpc_port = PortSpec(number=9090, transport_protocol="TCP", application_protocol="http")
    validator_rpc_port = PortSpec(number=26657,transport_protocol="TCP", application_protocol="http")

    # celestia-node
    bridge_rpc_port = PortSpec(number=26658, transport_protocol="TCP", application_protocol="http")
    bridge_rest_port = PortSpec(number=26659, transport_protocol="TCP", application_protocol="http")

    # setup
    ports = { 
        "validator-grpc": validator_grpc_port,
        "validator-rpc": validator_rpc_port,
        "bridge-rpc": bridge_rpc_port,
        "bridge-rest": bridge_rest_port
    }

    service_config = ServiceConfig(
        image="ghcr.io/rollkit/local-celestia-devnet:v0.13.1",
        env_vars=env_vars,
        ports=ports,
        public_ports=ports,
    )

    local_da = plan.add_service(name="celestia-local",config=service_config)
   
    local_da_validator = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["validator-rpc"].number
    )

    local_da_bridge = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["bridge-rpc"].number
    )

    return (local_da_validator, local_da_bridge)
    