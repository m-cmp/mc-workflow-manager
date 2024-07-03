<template>
  <Modal ref="baseModal">
    <!--begin::Modal header-->
    <div class="modal-header" id="kt_modal_user_header">
      <!--begin::Modal title-->
      <h2 class="fw-bolder">{{ modalTitle }} a User</h2>
      <!--end::Modal title-->

      <!--begin::Close-->
      <div
        @click="onCancel"
        class="btn btn-icon btn-sm btn-active-icon-primary"
      >
        <span class="svg-icon svg-icon-1">
          <inline-svg src="media/icons/duotune/arrows/arr061.svg" />
        </span>
      </div>
      <!--end::Close-->
    </div>
    <!--end::Modal header-->

    <!--begin::Modal body-->
    <div class="modal-body py-10 px-lg-17">
      <!--begin::Form-->
      <el-form
        @submit.prevent="onSubmit()"
        :model="formData"
        :rules="rules"
        ref="formRef"
      >
        <!--begin::Input group-->
        <div class="d-flex flex-column mb-8 fv-row">
          <!--begin::Label-->
          <label class="required fs-6 fw-bold mb-2">Name</label>
          <!--end::Label-->

          <!--begin::Input-->
          <el-form-item prop="username">
            <el-input
              v-model="formData.username"
              type="text"
              placeholder=""
              name="username"
            />
          </el-form-item>
          <!--end::Input-->
        </div>
        <!--end::Input group-->

        <!--begin::Input group-->
        <div class="d-flex flex-column mb-8 fv-row">
          <!--begin::Label-->
          <label class="required fs-6 fw-bold mb-2">Email</label>
          <!--end::Label-->

          <!--begin::Input-->
          <el-form-item prop="email">
            <el-input
              v-model="formData.email"
              type="text"
              placeholder=""
              name="email"
            />
          </el-form-item>
          <!--end::Input-->
        </div>
        <!--end::Input group-->

        <!--begin::Input group-->
        <div class="row g-9 mb-8">
          <!--begin::Col-->
          <div class="col-md-6 fv-row">
            <label class="required fs-6 fw-bold mb-2">City</label>

            <!--begin::Input-->
            <el-form-item prop="city">
              <el-select
                v-model="formData.city"
                name="city"
                as="select"
                style="width: 100%"
              >
                <el-option value="">Select a City...</el-option>
                <el-option v-for="city in cityData" :key="city" :value="city">
                  {{ city }}
                </el-option>
              </el-select>
            </el-form-item>
            <!--end::Input-->
          </div>
          <!--end::Col-->

          <!--begin::Col-->
          <div class="col-md-6 fv-row">
            <label class="required fs-6 fw-bold mb-2">Due Date</label>

            <!--begin::Input-->
            <div class="position-relative align-items-center">
              <!--begin::Datepicker-->
              <el-form-item prop="dueDate">
                <el-date-picker
                  v-model="formData.dueDate"
                  placeholder="Select a date"
                  name="dueDate"
                  style="width: 100%"
                />
              </el-form-item>
              <!--end::Datepicker-->
            </div>
            <!--end::Input-->
          </div>
          <!--end::Col-->
        </div>
        <!--end::Input group-->

        <!--begin::Input group-->
        <div class="d-flex flex-column mb-8 fv-row">
          <!--begin::Label-->
          <label class="fs-6 fw-bold mb-2">Company</label>
          <!--end::Label-->

          <!--begin::Input-->
          <el-form-item prop="company">
            <el-input
              v-model="formData.company"
              type="text"
              placeholder=""
              name="company"
            />
          </el-form-item>
          <!--end::Input-->
        </div>
        <!--end::Input group-->

        <!--begin::Actions-->
        <div class="text-center">
          <button type="reset" class="btn btn-light me-3" @click="onCancel">
            Cancel
          </button>

          <!--begin::Button-->
          <button
            :data-kt-indicator="loading ? 'on' : null"
            class="btn btn-lg btn-primary"
            type="submit"
          >
            <span v-if="!loading" class="indicator-label">
              Submit
              <span class="svg-icon svg-icon-3 ms-2 me-0">
                <inline-svg src="icons/duotune/arrows/arr064.svg" />
              </span>
            </span>
            <span v-if="loading" class="indicator-progress">
              Please wait...
              <span
                class="spinner-border spinner-border-sm align-middle ms-2"
              ></span>
            </span>
          </button>
          <!--end::Button-->
        </div>
        <!--end::Actions-->
      </el-form>
      <!--end:Form-->
    </div>
    <!--end::Modal body-->
  </Modal>
</template>

<script lang="ts">
import Modal from "@/components/base/user/Modal.vue";
import { ref, onUpdated } from "vue";
import Swal from "sweetalert2/dist/sweetalert2.js";
import axios from "axios";

interface IFormData {
  id: number;
  username: string;
  email: string;
  city: string;
  dueDate: string;
  company: string;
}

export default {
  name: "ConfirmationModal",
  components: {
    Modal,
  },
  // 렌더링할 객체를 가져옵니다.
  props: ["modalParam", "modalTitle"],
  setup(props) {
    const formRef = ref<null | HTMLFormElement>(null);
    const loading = ref<boolean>(false);
    // 자식 컴포넌트를 핸들링하기 위한 ref
    const baseModal = ref();
    // Promise 객체를 핸들링하기 위한 ref
    const resolvePromise = ref();

    const formData = ref<IFormData>({
      id: -1,
      username: "",
      email: "",
      city: "",
      dueDate: "",
      company: "",
    });

    const rules = ref({
      username: [
        {
          required: true,
          message: "Username is required",
          trigger: "change",
        },
      ],
      email: [
        {
          required: true,
          trigger: "change",
          type: "email",
        },
      ],
      city: [
        {
          required: true,
          message: "City is required",
          trigger: "change",
        },
      ],
      dueDate: [
        {
          required: true,
          message: "Please select Activity zone",
          trigger: "change",
        },
      ],
    });

    onUpdated(() => {

      if (props.modalParam.id != null) {
        formData.value.id = props.modalParam.id;
        formData.value.username = props.modalParam.username;
        formData.value.email = props.modalParam.email;
        formData.value.city = props.modalParam.address.city;
        formData.value.company = props.modalParam.company.name;

      } else {
        formData.value.id = -1;
        formData.value.username = "";
        formData.value.email = "";
        formData.value.city = "";
        formData.value.company = "";
        formRef.value?.reset;
      }
    });

    const cityData = ref([]);

    const onShow = () => {
      console.log("props.modalParam setup : ", props.modalParam);
      axios
        .get("https://jsonplaceholder.typicode.com/users")
        .then(({ data }) => {
          for (let i = 0; i < data.length; i++) {
            cityData.value.push(data[i].address.city as never);
          }
          console.log("cityData : ", cityData);
        });

      // baseModal을 직접 컨트롤합니다.
      baseModal.value.open();

      // Promise 객체를 사용하여, 현재 모달에서 확인 / 취소의
      // 응답이 돌아가기 전까지 작업을 기다리게 할 수 있습니다.
      return new Promise((resolve) => {
        // resolve 함수를 담아 외부에서 사용합니다.
        resolvePromise.value = resolve;
      });
    };

    const onCancel = () => {
      baseModal.value.close();
      resolvePromise.value(null);
    };

    //Form submit function
    const onSubmit = () => {
      if (!formRef.value) {
        return;
      }

      formRef.value.validate((valid) => {
        console.log("formData : ", formData.value);
        if (valid) {
          loading.value = true;

          setTimeout(() => {
            loading.value = false;

            if (props.modalParam.id < 0) {
              alert("Insert!!!!");
            } else {
              alert("Update!!!!");
            }

            Swal.fire({
              text: "Form has been successfully submitted!",
              icon: "success",
              buttonsStyling: false,
              confirmButtonText: "Ok, got it!",
              customClass: {
                confirmButton: "btn btn-primary",
              },
            }).then(() => {
              baseModal.value.close();
              resolvePromise.value(true);
            });
          }, 2000);
        } else {
          Swal.fire({
            text: "Sorry, looks like there are some errors detected, please try again.",
            icon: "error",
            buttonsStyling: false,
            confirmButtonText: "Ok, got it!",
            customClass: {
              confirmButton: "btn btn-primary",
            },
          });
          return false;
        }
      });
    };

    return {
      baseModal,
      formRef,
      cityData,
      onShow,
      onCancel,
      formData,
      loading,
      onSubmit,
      rules,
    };
  },
};
</script>
