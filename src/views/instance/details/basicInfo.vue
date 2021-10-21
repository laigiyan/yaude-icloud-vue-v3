<template>
  <div style="background-color: #ececec; padding: 20px;">
    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="實例信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>ID: {{ serverDetail.id }}</p>
          <p>實例名稱: {{ serverDetail.instanceName }}</p>
          <p>專案名稱: {{ serverDetail.projectName }}</p>
          <p>狀態: {{ serverDetail.status }}</p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="網路信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>IP 位址: {{ serverDetail.ipAddress }}</p>
          <p></p>
          <p></p>
          <p></p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="配置信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>內存: {{ serverDetail.ramText }}</p>
          <p>硬碟: {{ serverDetail.diskText }}</p>
          <p>CPU: {{ serverDetail.cpu }}</p>
          <p></p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="映像檔信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>id: {{ serverDetail.imgId }}</p>
          <p>名稱: {{ serverDetail.imgName }}</p>
          <p></p>
          <p></p>
          <p></p>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>


<script>
  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'

  export default {
    name: 'basicInfo',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
    },
    data () {
      return {
        description: '實例基本信息',
        serverDetail:{},
        // 表頭
        url: {
          list: "/openstack/osInstance/getServerDetailById",

        },
      }
    },
    props:{
      dataSource:{
        type: Object,
        default: ()=>{},
        required: false
      }
    },
    created() {
      this.loadServerDetail(this.dataSource.id);
    },
    methods: {
      loadServerDetail(id) {
        if(!this.url.list){
          this.$message.error("請設置url.list屬性!")
          return
        }
        this.loading = true;
        var that = this;
        getAction(this.url.list, { id:id,projectId:this.dataSource.projectId }).then((res) => {
          debugger;
          if (res.success) {
            debugger;
            that.serverDetail = res.result;
          }else{
            that.$message.warning(res.message)
          }
        }).finally(() => {
          that.loading = false
        })
      },

    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>