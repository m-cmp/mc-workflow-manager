<template>
  <div class="table-responsive mt-5">
  <table class="table table-row-bordered table-row-gray-300 align-middle gs-0 gy-3">
    <thead>
      <tr class="fw-bolder text-muted bg-light">
          <th class="ps-5 min-w-650px rounded-start" :colspan="2">{{ data.transCodeNm }}</th>
          <th class="min-w-100px text-center">
            {{ $t("authority.page.organizationOwner") }}
          </th>
          <!-- yyr : - add service owner 권한 테이블 추가 -->
          <th class="min-w-100px text-center">
            {{ $t("authority.page.serviceOwner") }}
          </th>
          <th class="min-w-100px text-center">
            {{ $t("authority.page.projectManager") }}
          </th>
          <th class="min-w-80px text-center text-end rounded-end">
            {{ $t("authority.page.developer") }}
          </th>
      </tr>
    </thead>
    <tbody class="border-bottom-3">
      <template v-for="group in data.children">
        <tr v-for="(item, index) in group.items" :key="item.transCode">
          <template v-if="item.code == -100 || index == 0">
            <td :rowspan="group.items.length" class="w-150px text-center">
              <b>{{ $t(group.transCode) }}</b>
            </td>
          </template>
          <td class="h-50px "><span class="ms-3">{{ $t(item.transCode) }}</span></td>
          <td class="text-center">
            <input
              v-model="item.values.group"
              type="checkbox"
              @change="
                onChangeField(item.code, group, 'group', $event.target.checked)
              "
            />
            <!-- <el-checkbox v-model="item.values.group" @change="onChangeField(group, 'group',  $event)"></el-checkbox> -->
          </td>
          <td class="text-center">
            <input
              v-model="item.values.service"
              type="checkbox"
              @change="
                onChangeField(
                  item.code,
                  group,
                  'service',
                  $event.target.checked
                )
              "
            />
            <!-- <el-checkbox v-model="item.values.project" @change="onChangeField(group, 'service',  $event)"></el-checkbox> -->
          </td>
          <td class="text-center">
            <input
              v-model="item.values.project"
              type="checkbox"
              @change="
                onChangeField(
                  item.code,
                  group,
                  'project',
                  $event.target.checked
                )
              "
            />
            <!-- <el-checkbox v-model="item.values.project" @change="onChangeField(group, 'project',  $event)"></el-checkbox> -->
          </td>
          <td class="text-center">
            <input
              v-model="item.values.developer"
              type="checkbox"
              @change="
                onChangeField(
                  item.code,
                  group,
                  'developer',
                  $event.target.checked
                )
              "
            />
            <!-- <el-checkbox v-model="item.values.developer" @change="onChangeField(group, 'developer',  $event)"></el-checkbox> -->
          </td>
        </tr>
      </template>
    </tbody>
  </table>
  </div>
</template>
<script>
export default {
  props: {
    data: {
      type: Object,
      default: null,
    },
    authIdMap: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {};
  },
  methods: {
    // 전체 필드 체크 처리
    // 검색해서 필드가 체크되어 있으면 All필드도 선택 처리 한다.
    checkedAll(group, action) {
      let checked = true;
      for (var i = 1; i < group.items.length; i++) {
        const item = group.items[i];
        if (item.values[action] == false) {
          checked = false;
          break;
        }
      }
      group.items[0].values[action] = checked;
    },

    onChangeField(code, group, action, value) {
      const changeList = [];
      // all 설정인 경우
      if (code == -100) {
        group.items.forEach((item) => {
          const oldValue = item.values[action];
          item.values[action] = value;

          if (oldValue != value) {
            changeList.push({
              authId: this.authIdMap[action],
              authCode: item.code,
              use: value,
            });
          }
        });
        // 단일 설정인 경우
      } else {
        // 전체 설정인 경우 all check를 true,false로 변경
        this.checkedAll(group, action);
        changeList.push({
          authId: this.authIdMap[action],
          authCode: code,
          use: value,
        });
      }

      this.emitChanageEvent(changeList);
    },

    emitChanageEvent(changeList) {
      console.log("____________ ", changeList);
      this.$emit("change", changeList);
    },
  },
};
</script>