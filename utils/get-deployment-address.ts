import deployments from "../deployments.json";
import { getDeployment as getForgeDeployment } from "forge-utils";

export const getDeploymentAddress = (chainId: string | number, env?: string) => {
    return getForgeDeployment(deployments, chainId, env)
}
