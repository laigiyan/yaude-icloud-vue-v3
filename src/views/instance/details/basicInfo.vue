<template>
  <div style="background-color: #ececec; padding: 20px;">
    <a-row :gutter="24">
      <a-col :span="12">
        <a-card title="實例信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>ID: {{ serverDetail.id }}</p>
          <p>實例名稱: {{ serverDetail.instanceName }}</p>
          <p>項目名稱: {{ serverDetail.projectName }}</p>
          <p>狀態: {{ serverDetail.status }}</p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="網絡信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>IP地址: {{ serverDetail.ipAddress }}</p>
          <p></p>
          <p></p>
          <p></p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="配置信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
          <p>内存: {{ serverDetail.ramText }}</p>
          <p>磁盤: {{ serverDetail.diskText }}</p>
          <p>CPU: {{ serverDetail.cpu }}</p>
          <p></p>
          <p></p>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="鏡像信息" :bordered="false" :style="{ marginBottom: '24px',minHeight:'250px' }">
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
        description: '实例基本信息',
        serverDetail:{},
        // 表头
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
          this.$message.error("请设置url.list属性!")
          return
        }
        this.loading = true;
        var that = this;
        getAction(this.url.list, { id:id }).then((res) => {
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