
const DeployError = {
// 데이터 초기화 에러
	DATA_INIT_ERROR:"dataInitError",
	DEPLOY_ERROR: "deployError" 
}

export default DeployError;
// class DeployError extends Error {
//     constructor(code = DEPLOY_ERROR, status = 200, ...params) {
//         super(...params)

//         if (Error.captureStackTrace) {
//             Error.captureStackTrace(this, DeployError)
//         }

//         this.code = code
//         this.status = status
//     }
// }

// export default DeployError