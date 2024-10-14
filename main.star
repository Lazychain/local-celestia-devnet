# This Kurtosis package spins up a local Celestia based on rollkit 
# https://github.com/rollkit/local-celestia-devnet


def run(
    plan,
    chain_id="test",
    dummy_mnemonic="", # this must be provided
    validator_grpc_port=9090,
    validator_rpc_port=26657,
    bridge_rpc_port=26658,
    bridge_rest_port=26659
    ):
    # config
    env_vars = {}
    env_vars["CELESTIA_NAMESPACE"] = "lazy_namespace"
    service_name="celestia-local"

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

    local_da = plan.add_service(name=service_name,config=service_config)

    # Create development account
    cmd="echo \"{0}\" | celestia-appd keys add dev01 --keyring-backend test --output json --recover | jq '.address |add'".format(dummy_mnemonic)
    create_dev_wallet = plan.exec(
        description="Creating Development Account",
        service_name=service_name,
        recipe=ExecRecipe(
            command=[
                "/bin/sh",
                "-c",
                cmd,
            ]
        ),
    )["output"]

    cmd = "celestia-appd keys list --keyring-backend test --output json | jq -r '[.[] | {(.name): .address}] | tostring | fromjson | reduce .[] as $item ({} ; . + $item)' | jq '.validator' | sed 's/\"//g;' | tr '\n' ' ' | tr -d ' '"
    validator_addr = plan.exec(
        description="Getting Validator address",
        service_name=service_name,
        recipe=ExecRecipe(
            command=[
                "/bin/sh",
                "-c",
                cmd,
            ]
        ),
    )["output"]

    cmd = "celestia-appd keys list --keyring-backend test --output json | jq -r '[.[] | {(.name): .address}] | tostring | fromjson | reduce .[] as $item ({} ; . + $item)' | jq '.dev01' | sed 's/\"//g;' | tr '\n' ' ' | tr -d ' '"
    dev_addr = plan.exec(
        description="Getting Dev01 Address",
        service_name=service_name,
        recipe=ExecRecipe(
            command=[
                "/bin/sh",
                "-c",
                cmd,
            ]
        ),
    )["output"]

    # kurtosis is so limited that we need to filter \n and to use that we need tr....
    cmd="celestia-appd tx bank send {0} {1} 1000000utia --keyring-backend test --fees 500utia -y".format(validator_addr,dev_addr)

    fund_wallet = plan.exec(
        description="Funding dev wallet {0}".format(dev_addr),
        service_name=service_name,
        recipe=ExecRecipe(
            command=[
                "/bin/sh",
                "-c",
                cmd,
            ]
        ),
    )["output"]

    return { "validator_addr" : validator_addr, "dev_addr" : dev_addr }
    
