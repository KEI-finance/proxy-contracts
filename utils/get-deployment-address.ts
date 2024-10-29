import deployments from '../deployments.json';
import {getDeploymentAddress as getForgeDeploymentAddress} from 'forge-utils';

export const getDeploymentAddress = (
  name: string,
  chainId: string | number,
  env?: string,
) => {
  return getForgeDeploymentAddress(deployments, name, chainId, env);
};
