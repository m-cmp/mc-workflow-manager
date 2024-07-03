import { ERROR_TYPE } from "@/constant/error";
import Vue from "vue";


const DevOps = {
    install(Vue, options) {
        Vue.prototype.$errorMessage = function(type, title, message) {
            this.$store.dispatch("errorLog/setErrorMessage", {
                title: title,
                message: message
            });

            this.$router.push({ path: "/error" });
        };

        Vue.prototype.$dataError = function(error) {
            let title = title || ERROR_TYPE.DATA_ERROR;
            //message = error.message || "서버 호출이 실패했습니다.";
            let message = this.$t("error.dataError");
            this.$store.dispatch("errorLog/setErrorMessage", {
                title: title,
                message: message
            });

            this.$router.push({ path: "/error" });
        };

        /*
            데이터 에러 처리
        */
        Vue.prototype.$dataErrorMessage = function(message, title = null) {
            title = title || ERROR_TYPE.DATA_ERROR;
            this.$store.dispatch("errorLog/setErrorMessage", {
                title: title,
                message: message
            });

            this.$router.push({ path: "/error" });
        };

        /*
            데이터 에러 처리 : id에 해당하는 메시지를 자동으로 설정해주기
            현재  id에 해당하는 정보는 존재하지 않음. 추후 추가해야함.
            2020.03.11 ddan
        */
        Vue.prototype.$dataErrorMessageId = function(messageId, title = null) {
            title = title || ERROR_TYPE.DATA_ERROR;

            /*
                messageId에 해당하는 메시지 추가해야함.
            */
            this.$store.dispatch("errorLog/setErrorMessage", {
                title: title,
                message: message
            });
            this.$router.push({ path: "/error" });
        };

        Vue.prototype.$validateListData = function(response) {
            if (response.hasOwnProperty("data") === false) {
                this.$dataErrorMessage(this.$t("error.formatError"));
                return false;
            }
            return true;
        };

        Vue.prototype.isNumber=function($event){
            let keyCode = ($event.keyCode ? $event.keyCode : $event.which);
            if ((keyCode < 48 || keyCode > 57) && keyCode !== 46) { // 46 is dot
                $event.preventDefault();
            }
		}

		Vue.prototype.isAlphaNumber = function ($event) {


		}

        Vue.$errorMessage = function (message, title) {
            title = title || ERROR_TYPE.DATA_ERROR;
            Vue.app.$store.dispatch("errorLog/setErrorMessage", {
                title: title,
                message: message
            });

            Vue.app.$router.push({ path: "/error" });
		}

		/*
			영문자,숫자만 입력 될 수 있게
		*/
		Vue.directive("alphaNumber", {
			bind: function (el, binding, vnode) {
				el.addEventListener("input", function (e) {
					e.target.value=e.target.value.replace(/[^A-Za-z0-9]/gi, "");
				})
			}
		})

		Vue.directive("alphaNumericHyphen",
			function(el,binding){
				el.addEventListener('input', (event) => {
					binding.value.target[binding.value.fieldName] = event.target.value.replace(/[^A-Za-z0-9-]/, "");
				})
			}
		)

		Vue.directive("appName",
			function(el,binding){
				el.addEventListener('input', (event) => {
					binding.value.target[binding.value.fieldName] = event.target.value.replace(/[^a-z0-9-]/, "");
				})
			}
		)



    },

    setApp(app) {
        Vue.app = app;
            // 시작 시 moment locale 설정
        app.$moment.locale(app.$i18n.locale)

    }
};

export default DevOps;
