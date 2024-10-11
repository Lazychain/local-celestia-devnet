# This Kurtosis package spins up a local Celestia based on rollkit 
# https://github.com/rollkit/local-celestia-devnet


def run(plan):
    # config
    env_vars = {}
    env_vars["CELESTIA_NAMESPACE"] = "lazy_namespace"

    # celestia-app
    validator_grpc_port = 9090
    validator_rpc_port = 26657

    # celestia-node
    bridge_grpc_port = 26650
    bridge_rpc_port = 26658
    bridge_rest_port = 26659

    # setup
    port_spec = PortSpec(
        number=port_number,
        transport_protocol="TCP",
        application_protocol="http",
    )

    ports = { 
        "validator_grpc_port": validator_grpc_port,
        "validator_rpc_port": validator_rpc_port,
        "bridge_grpc_port": bridge_grpc_port,
        "bridge_rpc_port": bridge_rpc_port,
        "bridge_rest_port": bridge_rest_port
    }

    service_config = ServiceConfig(
        image="ghcr.io/rollkit/local-celestia-devnet:v0.13.1",
        env_vars=env_vars,
        ports=ports,
        # TODO: expose different ports here
        public_ports=ports,
    )

    local_da = plan.add_service(name="celestia-local",config=service_config)
    
    local_da_validator = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["validator_grpc_port"].number
    )

    local_da_bridge = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["bridge_grpc_port"].number
    )

    return (local_da_validator, local_da_bridge)
    