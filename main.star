# This Kurtosis package spins up a local Celestia based on rollkit 
# https://github.com/rollkit/local-celestia-devnet


def run(
    plan,
    validator_grpc_port=9090,
    validator_rpc_port=26657,
    bridge_rpc_port=26658,
    bridge_rest_port=26659
    ):
    # config
    env_vars = {}
    env_vars["CELESTIA_NAMESPACE"] = "lazy_namespace"

    service_config = ServiceConfig(
        image="ghcr.io/rollkit/local-celestia-devnet:v0.13.1",
        env_vars=env_vars,
        ports={ 
            "validator-grpc": PortSpec(number=9090, transport_protocol="TCP", application_protocol="http"),
            "validator-rpc": PortSpec(number=26657,transport_protocol="TCP", application_protocol="http"),
            "bridge-rpc": PortSpec(number=26658, transport_protocol="TCP", application_protocol="http"),
            "bridge-rest": PortSpec(number=26659, transport_protocol="TCP", application_protocol="http")
        },
        public_ports={ 
            "validator-grpc": PortSpec(number=validator_grpc_port, transport_protocol="TCP", application_protocol="http"),
            "validator-rpc": PortSpec(number=validator_rpc_port,transport_protocol="TCP", application_protocol="http"),
            "bridge-rpc": PortSpec(number=bridge_rpc_port, transport_protocol="TCP", application_protocol="http"),
            "bridge-rest": PortSpec(number=bridge_rest_port, transport_protocol="TCP", application_protocol="http")
        },
    )

    local_da = plan.add_service(name="celestia-local",config=service_config)
   
    local_da_validator = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["validator-rpc"].number
    )

    local_da_bridge = "http://{0}:{1}".format(
        local_da.ip_address, local_da.ports["bridge-rpc"].number
    )

    return (local_da_validator, local_da_bridge)
    